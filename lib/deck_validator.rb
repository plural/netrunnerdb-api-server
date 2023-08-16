class DeckValidator

  attr_reader :valid
  attr_reader :validations
  attr_reader :errors

  # TODO: make error codes with maps for messages to aid translation and testing.
  def initialize(deck)
    @deck = deck.deep_dup
    # Force all keys to lowercase, which includes card ids from the cards object.
    @deck.deep_transform_keys!(&:downcase)
    # Force values for fields specifying IDs to lowercase.
    ['identity_card_id', 'side_id'].each do |k|
      if @deck.has_key?(k)
        @deck[k].downcase!
      end
    end

    @validation_performed = false

    @valid = false
    # Errors accumulated through the validation process.
    @errors = []
    # All valid cards specified in the deck.
    @cards = {}
    # All requested validations, used to keep specific errors tied to the validations requested.
    @validations = []

    if @deck.has_key?('validations')
      @deck['validations'].each do |v|
        @validations << DeckValidation.new(v)
      end
    end

    @validation_errors = false
  end

  def is_valid?
    if not @validation_performed
      @validation_performed = true
      if all_required_fields_present?
        load_cards_from_deck
        if all_ids_exist?
          @validations.each do |v|
            if v.basic_deckbuilding_rules
              check_basic_deckbuilding_rules.each do |e|
                v.add_error(e)
                @validation_errors = true
              end
            end
          end
        end
      end
    end

    return (@errors.size == 0 and !@validation_errors)
  end

  private

  def all_required_fields_present?
    # Deck must have identity_card_id specified.
    if not @deck.has_key?('identity_card_id')
      @errors << "Deck is missing `identity_card_id` field."
    end

    # Deck must have side_id specified.
    if not @deck.has_key?('side_id')
      @errors << "Deck is missing `side_id` field."
    end

    # Deck must have a cards array with at least 1 card.
    if not @deck.has_key?('cards') or (@deck.has_key?('cards') and @deck['cards'].size == 0)
      @errors << "Deck must specify some cards."
    end

    # A list of validations must be present with at least 1 item.
    if not @deck.has_key?('validations') or (@deck.has_key?('validations') and @deck['validations'].size == 0)
      @errors << "Validation request must specify at least one validation to perform."
    end

    return @errors.size == 0
  end

  def load_cards_from_deck
    # Populate @cards by retrieving cards specified in the deck.
    Card.where(id: [@deck['identity_card_id']] + @deck['cards'].keys).each {|c| @cards[c.id] = c}
  end

  def all_ids_exist?
    # identity_card_id is valid
    if not @cards.has_key?(@deck['identity_card_id'])
      @errors << '`identity_card_id` `%s` does not exist.' % @deck['identity_card_id']
    end

    # side_id is valid
    if not ['corp', 'runner'].include?(@deck['side_id'])
      @errors << '`side_id` `%s` does not exist.' % @deck['side_id']
    end

    @deck['cards'].each do |card_id, quantity|
      if !@cards.has_key?(card_id.to_s)
        @errors << 'Card `%s` does not exist.' % card_id
      end
    end

    # Check all format, snapshot, card pool, restriction id values as well.

    return @errors.size == 0
  end

  def check_basic_deckbuilding_rules
    local_errors = []
    # identity_card_id side matches deck side
    if @cards[@deck['identity_card_id']].side_id != @deck['side_id']
      local_errors << 'Identity `%s` has side `%s` which does not match given side `%s`' % [@deck['identity_card_id'], @cards[@deck['identity_card_id']].side_id, @deck['side_id']]
    end

    # Ensure that all card ids exist and match the side of the identity.
    @deck['cards'].each do |card_id, quantity|
      if @deck['side_id'] != @cards[card_id.to_s].side_id
        local_errors << 'Card `%s` side `%s` does not match deck side `%s`' % [card_id, @cards[card_id.to_s].side_id, @deck['side_id']]
      end
    end

    identity = @cards[@deck['identity_card_id']]

    # Check deck size minimums
    num_cards = @deck['cards'].map{ |slot, quantity| quantity }.sum
    if num_cards < identity.minimum_deck_size
      local_errors << "Minimum deck size is %d, but deck has %d cards." % [identity.minimum_deck_size, num_cards]
    end

    # Check cards against deck limits.
    @deck['cards'].each do |card_id, quantity|
      limit = ['ampere_cybernetics_for_anyone', 'nova_initiumia_catalyst_impetus'].include?(identity.id) ? 1 : @cards[card_id.to_s].deck_limit
      if quantity > limit
        local_errors << 'Card `%s` has a deck limit of %d, but %d copies are included.' % [card_id, limit, quantity]
      end
    end

    # Check Corp decks for deck-size based agenda points restrictions.
    if @deck['side_id'] == 'corp'
      agenda_points = @cards.select {|card_id| @cards[card_id].card_type_id == 'agenda'}.map{|card_id, card| card.agenda_points * @deck['cards'][card_id] }.sum

      min_agenda_points = (num_cards < identity.minimum_deck_size ? identity.minimum_deck_size : num_cards) / 5 * 2 + 2
      required_agenda_points = [min_agenda_points, min_agenda_points + 1]
      if not required_agenda_points.include?(agenda_points)
        local_errors << "Deck with size %d requires %s agenda points, but deck only has %d" % [num_cards, required_agenda_points.to_json, agenda_points]
      end
    end

    # Check agenda faction restrictions.
    if identity.id == 'ampere_cybernetics_for_anyone'
      # Ampere may only have 2 agendas per non-neutral faction.
      faction_agenda_count = {}
      @cards.select{|card_id| @cards[card_id].card_type_id == 'agenda' and @cards[card_id].faction_id != 'neutral_corp'}.each do |card_id, card|
        if not faction_agenda_count.has_key?(card.faction_id)
          faction_agenda_count[card.faction_id] = 0
        end
        faction_agenda_count[card.faction_id] += 1
      end
      faction_agenda_count.each do |faction_id, count|
        if count > 2
          local_errors << "Ampere decks may not include more than 2 agendas per non-neutral faction. There are #{count} `#{faction_id}` agendas present."
        end
      end
    else
      @deck['cards']
        .select{|card_id| @cards[card_id].card_type_id == 'agenda' and not [identity.faction_id, 'neutral_corp'].include?(@cards[card_id].faction_id)}
        .each do |card_id, card|
          local_errors << "Agenda `#{card_id}` with faction_id `#{@cards[card_id].faction_id}` is not allowed in a `#{identity.faction_id}` deck."
      end
    end

    # Check influence
    if not identity.influence_limit.nil?
      influence_spent = @cards.select{|card_id| @cards[card_id].faction_id != identity.faction_id and (@cards[card_id].influence_cost.nil? ? false : @cards[card_id].influence_cost > 0)}
        .map{|card_id, card| card.influence_cost * @deck['cards'][card_id] }.sum
      # The Professor ignores the influence cost for the 1st copy of each program in the deck, so subtract that much influence.
      if identity.id == 'the_professor_keeper_of_knowledge'
        first_program_influence_spent = @cards.select{|card_id| @cards[card_id].faction_id != identity.faction_id and (@cards[card_id].influence_cost.nil? ? false : @cards[card_id].influence_cost > 0) and @cards[card_id].card_type_id == 'program'}
          .map{|card_id, card| card.influence_cost }.sum
          influence_spent = influence_spent - first_program_influence_spent
      end
      if influence_spent > identity.influence_limit
        local_errors << "Influence limit for %s is %d, but deck has spent %d influence" % [identity.title, identity.influence_limit, influence_spent]
      end
    end
    return local_errors
  end
end
