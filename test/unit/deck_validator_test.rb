class DeckValidatorTest < ActiveSupport::TestCase
  def setup
    @empty_deck = {}

    # Using => format to ensure that all keys remain strings, like we get in the web app.
    @missing_identity = { 'side_id' => 'corp' }
    @missing_side = { 'identity_card_id' => ''}

    @imaginary_identity = { 'identity_card_id' => 'plural', 'side_id' => 'corp', 'cards' => { 'hedge_fund' => 3 } }
    @imaginary_side = { 'identity_card_id' => 'geist', 'side_id' => 'super_mega_corp', 'cards' => { 'hedge_fund' => 3 } }

    @wrong_side_asa_group = { 'identity_card_id' => 'asa_group_security_through_vigilance', 'side_id' => 'runner' }
    @wrong_side_geist = { 'identity_card_id' => 'geist', 'side_id' => 'corp', 'cards' => { 'hedge_fund' => 3 } }

    @bad_cards_asa_group = { 'identity_card_id' => 'asa_group_security_through_vigilance', 'side_id' => 'corp', 'cards' => { 'foo' => 3, 'bar' => 3 } }
    @too_few_cards_asa_group = { 'identity_card_id' => 'asa_group_security_through_vigilance', 'side_id' => 'corp', 'cards' => { 'hedge_fund' => 3 } }

    @not_enough_agenda_points_too_many_copies = { 'identity_card_id' => 'asa_group_security_through_vigilance', 'side_id' => 'corp', 'cards' => { 'hedge_fund' => 36, 'project_vitruvius' => 9 } }

    @too_much_influence_asa_group = {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => {
        'ikawah_project' => 3,
        'project_vitruvius' => 3,
        'send_a_message' => 2,
        'regolith_mining_license' => 3,
        'spin_doctor' => 3,
        'trieste_model_bioroids' => 3,
        'biotic_labor' => 3,
        'hedge_fund' => 3,
        'punitive_counterstrike' => 3,
        'funhouse' => 3,
        'hagen' => 3,
        'hakarl_1_0' => 3,
        'enigma' => 3,
        'tollbooth' => 3,
        'ansel_1_0' => 3,
        'rototurret' => 3,
        'tyr' => 2,
      }
    }

    @good_asa_group = {
      'identity_card_id' => 'asa_group_security_through_vigilance',
      'side_id' => 'corp',
      'cards' => {
        'ikawah_project' => 3,
        'project_vitruvius' => 3,
        'send_a_message' => 2,
        'regolith_mining_license' => 3,
        'spin_doctor' => 3,
        'trieste_model_bioroids' => 3,
        'biotic_labor' => 3,
        'hedge_fund' => 3,
        'punitive_counterstrike' => 3,
        'eli_1_0' => 3,
        'hagen' => 3,
        'hakarl_1_0' => 3,
        'enigma' => 3,
        'tollbooth' => 3,
        'ansel_1_0' => 3,
        'rototurret' => 3,
        'tyr' => 2,
      }
    }
    @upper_case_asa_group = force_uppercase(@good_asa_group)
    @runner_econ_asa_group = swap_card(@good_asa_group, 'hedge_fund', 'sure_gamble')
    @out_of_faction_agenda = add_out_of_faction_agenda(@good_asa_group)

    @good_ampere = {
      'identity_card_id' => 'ampere_cybernetics_for_anyone',
      'side_id' => 'corp',
      'cards' => {
        'afshar' => 1,
        'aiki' => 1,
        'anoetic_void' => 1,
        'ansel_1_0' => 1,
        'argus_crackdown' => 1,
        'ark_lockdown' => 1,
        'artificial_cryptocrash' => 1,
        'audacity' => 1,
        'bathynomus' => 1,
        'bellona' => 1,
        'biotic_labor' => 1,
        'border_control' => 1,
        'celebrity_gift' => 1,
        'eli_1_0' => 1,
        'enigma' => 1,
        'envelopment' => 1,
        'fairchild_3_0' => 1,
        'formicary' => 1,
        'funhouse' => 1,
        'ganked' => 1,
        'hagen' => 1,
        'hakarl_1_0' => 1,
        'hansei_review' => 1,
        'hedge_fund' => 1,
        'hostile_takeover' => 1,
        'hybrid_release' => 1,
        'hydra' => 1,
        'ikawah_project' => 1,
        'jinja_city_grid' => 1,
        'lady_liberty' => 1,
        'longevity_serum' => 1,
        'luminal_transubstantiation' => 1,
        'punitive_counterstrike' => 1,
        'rashida_jaheem' => 1,
        'regolith_mining_license' => 1,
        'reversed_accounts' => 1,
        'ronin' => 1,
        'rototurret' => 1,
        'sds_drone_deployment' => 1,
        'send_a_message' => 1,
        'spin_doctor' => 1,
        'surveyor' => 1,
        'thimblerig' => 1,
        'tollbooth' => 1,
        'trieste_model_bioroids' => 1,
        'tyr' => 1,
        'urban_renewal' => 1,
        'urtica_cipher' => 1,
        'wraparound' => 1,
      }
    }

    @ampere_with_too_many_cards = set_card_quantity(set_card_quantity(@good_ampere, 'tyr', 2), 'hedge_fund', 2)
    @ampere_too_many_agendas_from_one_faction = swap_card(@good_ampere, 'hostile_takeover', 'ar_enhanced_security')

    @good_nova = {
      'identity_card_id' => 'nova_initiumia_catalyst_impetus',
      'side_id' => 'runner',
      'cards' => {
        'beth_kilrain_chang' => 1,
        'boomerang' => 1,
        'botulus' => 1,
        'bravado' => 1,
        'build_script' => 1,
        'bukhgalter' => 1,
        'career_fair' => 1,
        'cezve' => 1,
        'creative_commission' => 1,
        'daily_casts' => 1,
        'deuces_wild' => 1,
        'diesel' => 1,
        'dirty_laundry' => 1,
        'diversion_of_funds' => 1,
        'dr_nuka_vrolyck' => 1,
        'dreamnet' => 1,
        'earthrise_hotel' => 1,
        'emergent_creativity' => 1,
        'endurance' => 1,
        'falsified_credentials' => 1,
        'fermenter' => 1,
        'find_the_truth' => 1,
        'labor_rights' => 1,
        'liberated_account' => 1,
        'logic_bomb' => 1,
        'mad_dash' => 1,
        'miss_bones' => 1,
        'neutralize_all_threats' => 1,
        'no_free_lunch' => 1,
        'overclock' => 1,
        'paladin_poemu' => 1,
        'paperclip' => 1,
        'pinhole_threading' => 1,
        'simulchip' => 1,
        'stargate' => 1,
        'steelskin_scarring' => 1,
        'sure_gamble' => 1,
        'telework_contract' => 1,
        'the_class_act' => 1,
        'unity' => 1,
      }
    }

    @good_ken = {
      'identity_card_id' => 'ken_express_tenma_disappeared_clone',
      'side_id' => 'runner',
      'cards' => {
        'bravado' => 3,
        'carpe_diem' => 3,
        'dirty_laundry' => 3,
        'embezzle' => 2,
        'inside_job' => 2,
        'legwork' => 1,
        'marathon' => 2,
        'mutual_favor' => 2,
        'networking' => 1,
        'sure_gamble' => 3,
        'boomerang' => 2,
        'buffer_drive' => 1,
        'ghosttongue' => 1,
        'pennyshaver' => 2,
        'wake_implant_v2a_jrj' => 1,
        'aeneas_informant' => 3,
        'daily_casts' => 3,
        'dreamnet' => 1,
        'the_class_act' => 2,
        'aumakua' => 1,
        'bukhgalter' => 1,
        'cats_cradle' => 1,
        'paperclip' => 1,
        'bankroll' => 3,
      }
    }
    @corp_econ_ken = swap_card(@good_ken, 'sure_gamble', 'hedge_fund')
    @nova_with_too_many_cards = set_card_quantity(set_card_quantity(@good_nova, 'sure_gamble', 2), 'unity', 2)

    @good_professor = {
      'identity_card_id' => 'the_professor_keeper_of_knowledge',
      'side_id' => 'runner',
      'cards' => {
        'aumakua' => 1,
        'bankroll' => 1,
        'botulus' => 1,
        'bukhgalter' => 1,
        'cezve' => 1,
        'clot' => 1,
        'compile' => 2,
        'consume' => 1,
        'creative_commission' => 3,
        'cybertrooper_talut' => 2,
        'dirty_laundry' => 3,
        'dzmz_optimizer' => 2,
        'fermenter' => 1,
        'jailbreak' => 3,
        'leech' => 2,
        'mad_dash' => 2,
        'overclock' => 3,
        'prepaid_voicepad' => 2,
        'professional_contacts' => 2,
        'spec_work' => 2,
        'stargate' => 1,
        'sure_gamble' => 3,
        'tapwrm' => 1,
        'the_makers_eye' => 2,
        'top_hat' => 2,
      }
    }
    @too_much_program_influence_professor = set_card_quantity(set_card_quantity(@good_professor, 'consume', 2), 'stargate', 2)
  end

  def force_uppercase(deck)
    new_deck = deck.deep_dup
    new_deck.deep_transform_keys(&:upcase)
    new_deck['identity_card_id'].upcase!
    new_deck['side_id'].upcase!
    return new_deck
  end

  def swap_identity(deck, identity)
    new_deck = deck.deep_dup
    new_deck['identity_card_id'] = identity
    return new_deck
  end

  def swap_card(deck, old_card_id, new_card_id)
    new_deck = deck.deep_dup
    new_deck['cards'][new_card_id] = new_deck['cards'][old_card_id]
    new_deck['cards'].delete(old_card_id)
    return new_deck
  end

  def set_card_quantity(deck, card_id, quantity)
    new_deck = deck.deep_dup
    new_deck['cards'][card_id] = quantity
    return new_deck
  end

  def add_out_of_faction_agenda(deck)
    new_deck = deck.deep_dup
    new_deck['cards'].delete('send_a_message')
    new_deck['cards']['bellona'] = deck['cards']['send_a_message']
    return new_deck
  end

  def test_good_corp_side
    v = DeckValidator.new(@good_asa_group)
    assert v.is_valid?
    assert_equal 0, v.errors.size
  end

  def test_good_ampere
    v = DeckValidator.new(@good_ampere)
    assert v.is_valid?
    assert_equal 0, v.errors.size
  end

  def test_good_runner_side
    v = DeckValidator.new(@good_ken)
    assert v.is_valid?
    assert_equal 0, v.errors.size
  end

  def test_good_nova
    v = DeckValidator.new(@good_nova)
    assert v.is_valid?
    assert_equal 0, v.errors.size
  end

  def test_good_professor
    v = DeckValidator.new(@good_professor)
    assert v.is_valid?
    assert_equal 0, v.errors.size
  end

  def test_too_much_program_influence_professor
    v = DeckValidator.new(@too_much_program_influence_professor)
    assert !v.is_valid?
    assert_includes v.errors, "Influence limit for The Professor: Keeper of Knowledge is 1, but deck has spent 9 influence"
  end

  def test_case_normalization
    v = DeckValidator.new(@upper_case_asa_group)
    assert v.is_valid?
    assert_equal 0, v.errors.size
  end

  def test_empty_deck_json
    v = DeckValidator.new(@empty_deck)
    assert !v.is_valid?, 'Empty Deck JSON fails validation'
    assert_includes v.errors, "Deck is missing `identity_card_id` field."
    assert_includes v.errors, "Deck is missing `side_id` field."
    assert_includes v.errors, "Deck must specify some cards."
  end

  def test_missing_identity
    v = DeckValidator.new(@missing_identity)
    assert !v.is_valid?, 'Deck JSON missing identity fails validation'
    assert_includes v.errors, "Deck is missing `identity_card_id` field."
  end

  def test_missing_side
    v = DeckValidator.new(@missing_side)
    assert !v.is_valid?, 'Deck JSON missing side fails validation'
    assert_includes v.errors, "Deck is missing `side_id` field."
  end

  def test_imaginary_identity
    v = DeckValidator.new(@imaginary_identity)
    assert !v.is_valid?, 'Deck JSON has non-existent Identity'
    assert_includes v.errors, "`identity_card_id` `plural` does not exist."
  end

  def test_imaginary_side
    v = DeckValidator.new(@imaginary_side)
    assert !v.is_valid?, 'Deck JSON has non-existent side'
    assert_includes v.errors, "`side_id` `super_mega_corp` does not exist."
  end

  def test_corp_deck_with_runner_card
    v = DeckValidator.new(@runner_econ_asa_group)
    assert !v.is_valid?, 'Corp deck with runner card fails.'
    assert_includes v.errors, "Card `sure_gamble` side `runner` does not match deck side `corp`"
  end

  def test_out_of_faction_agendas
    v = DeckValidator.new(@out_of_faction_agenda)
    assert !v.is_valid?, 'Corp deck with out of faction agenda fails.'
    assert_includes v.errors, "Agenda `bellona` with faction_id `nbn` is not allowed in a `haas_bioroid` deck."
  end

  def test_out_of_faction_agendas_ampere
    v = DeckValidator.new(@ampere_too_many_agendas_from_one_faction)
    assert !v.is_valid?
    assert_includes v.errors, "Ampere decks may not include more than 2 agendas per non-neutral faction. There are 3 `nbn` agendas present."
  end

  def test_mismatched_side_corp_id
    v = DeckValidator.new(@corp_econ_ken)
    assert !v.is_valid?, 'Runner deck with corp card fails.'
    assert_includes v.errors, "Card `hedge_fund` side `corp` does not match deck side `runner`"
  end

  def test_mismatched_side_runner_id
    v = DeckValidator.new(@wrong_side_geist)
    assert !v.is_valid?, 'Deck with mismatched id and specified side fails'
    assert_includes v.errors, "Identity `geist` has side `runner` which does not match given side `corp`"
  end

  def test_not_enough_agenda_points
    v = DeckValidator.new(@not_enough_agenda_points_too_many_copies)
    assert !v.is_valid?
    assert_includes v.errors, "Deck with size 45 requires [20,21] agenda points, but deck only has 18"
  end

  def test_too_many_copies
    v = DeckValidator.new(@not_enough_agenda_points_too_many_copies)
    assert !v.is_valid?
    assert_includes v.errors, 'Card `hedge_fund` has a deck limit of 3, but 36 copies are included.'
    assert_includes v.errors, 'Card `project_vitruvius` has a deck limit of 3, but 9 copies are included.'
  end

  def test_too_many_copies_ampere
    v = DeckValidator.new(@ampere_with_too_many_cards)
    assert !v.is_valid?
    assert_includes v.errors, "Card `hedge_fund` has a deck limit of 1, but 2 copies are included."
    assert_includes v.errors, "Card `tyr` has a deck limit of 1, but 2 copies are included."
  end

  def test_too_may_copies_nova
    v = DeckValidator.new(@nova_with_too_many_cards)
    assert !v.is_valid?
    assert_includes v.errors, "Card `sure_gamble` has a deck limit of 1, but 2 copies are included."
    assert_includes v.errors, "Card `unity` has a deck limit of 1, but 2 copies are included."
  end

  def test_corp_too_much_influence
    v = DeckValidator.new(@too_much_influence_asa_group)
    assert !v.is_valid?
    assert_includes v.errors, "Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence"
  end

  def test_bad_cards
    v = DeckValidator.new(@bad_cards_asa_group)
    assert !v.is_valid?
    assert_includes v.errors, "Card `foo` does not exist."
    assert_includes v.errors, "Card `bar` does not exist."
  end

  def test_too_few_cards
    v = DeckValidator.new(@too_few_cards_asa_group)
    assert !v.is_valid?
    assert_includes v.errors, "Minimum deck size is 45, but deck has 3 cards."
  end
end