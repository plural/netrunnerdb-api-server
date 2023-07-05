class DeckValidator

  attr_reader :valid
  attr_reader :errors

  # TODO: make error codes with maps for messages to aid translation and testing.
  def initialize
    @valid = false
    @errors = []
  end

  def validate(deck_json)
    if passes_request_validity?(deck_json)
      passes_basic_deckbuilding_rules?(deck_json)
    end

    return @errors.size == 0
  end

  def passes_request_validity?(deck)
    # normalize to lowercase for all ids.

    # has identity_card_id
    has_identity = deck.has_key?(:identity_card_id)
    if not has_identity
      @errors << "Deck is missing `identity_card_id` field."
    end

    # has side_id
    has_side = deck.has_key?(:side_id)
    if not has_side
      @errors << "Deck is missing `side_id` field."
    end

    id_to_side = {}
    sides = {}
    Card.where(:card_type_id => ['corp_identity', 'runner_identity']).pluck(:id, :side_id).each do |id, side|
      id_to_side[id] = side
      sides[side] = true
    end

    # identity_card_id is valid
    if has_identity
      if not id_to_side.has_key?(deck[:identity_card_id])
        @errors << '`identity_card_id` `%s` does not exist.' % deck[:identity_card_id]
      end
    end

    # side_id is valid
    if has_side
      if not sides.has_key?(deck[:side_id])
        @errors << '`side_id` `%s` does not exist.' % deck[:side_id]
      end
    end

    # identity_card_id side matches deck side
    if has_identity and has_side
      if id_to_side[deck[:identity_card_id]] != deck[:side_id]
        @errors << 'Identity `%s` has side `%s` which does not match given side `%s`' % [deck[:identity_card_id], id_to_side[deck[:identity_card_id]], deck[:side_id]]
      end
    end

    if deck.has_key?(:cards) and deck[:cards].size > 0
      # Ensure that all card ids exist.
      card_ids = Set.new(Card.all().pluck(:id))
      deck[:cards].each do |card_id, quantity|
        if !card_ids.include?(card_id.to_s)
          @errors << 'Card `%s` does not exist.' % card_id
        end
      end
    else
      @errors << "Deck must specify some cards."
    end

    return @errors.size == 0
  end

  def passes_basic_deckbuilding_rules?(deck)
    # Check deck size minimums
    identity = Card.find(deck[:identity_card_id])

    num_cards = deck[:cards].map{ |slot, quantity| quantity }.sum
    if num_cards < identity.minimum_deck_size
      @errors << "Minimum deck size is %d, but deck has %d cards." % [identity.minimum_deck_size, num_cards]
    end

    # TODO: Check max quantity of each card

    # If corp deck, check agenda points
    if deck[:side_id] == 'corp'
      agendas_with_points = {}
      Card.where({id: deck[:cards].map{|card_id, quantity| card_id}, card_type_id: 'agenda'}).each {|c| agendas_with_points[c.id] = c.agenda_points}
      agenda_points = agendas_with_points.map{|card_id, points| points * deck[:cards][card_id.to_sym] }.sum

      min_agenda_points = (num_cards < identity.minimum_deck_size ? identity.minimum_deck_size : num_cards) / 5 * 2 + 2
      required_agenda_points = [min_agenda_points, min_agenda_points + 1]
      if not required_agenda_points.include?(agenda_points)
        errors << "Deck with size %d requires %s agenda points, but deck only has %d" % [num_cards, required_agenda_points.to_json, agenda_points]
      end
    end

    # TODO: add special Professor influence rules.
    # TODO: add special Ampere agenda rules.
    # TODO: add special Nova influence rules.
    # Check influence
    out_of_faction_cards = {}
    Card.where(id: deck[:cards].map{|card_id, quantity| card_id}).where.not(influence_cost: [nil, 0]).where.not(faction_id: identity.faction_id).each {|c| out_of_faction_cards[c.id] = c.influence_cost }
    influence_spent = out_of_faction_cards.map{|card_id, influence| influence * deck[:cards][card_id.to_sym] }.sum
    if influence_spent > identity.influence_limit
      @errors << "Influence limit for %s is %d, but deck has spent %d influence" % [identity.title, identity.influence_limit, influence_spent]
    end

    return @errors.size == 0
  end
end
