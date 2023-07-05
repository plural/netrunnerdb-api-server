class DeckValidatorTest < ActiveSupport::TestCase
  def setup
    @empty_deck = {}

    @missing_identity = { side_id: 'corp' }
    @missing_side = { identity_card_id: ''}

    @imaginary_identity = { identity_card_id: 'plural', side_id: 'corp' }
    @imaginary_side = { identity_card_id: 'geist', side_id: 'super_mega_corp' }

    @wrong_side_asa_group = { identity_card_id: 'asa_group', side_id: 'runner' }
    @wrong_side_geist = { identity_card_id: 'geist', side_id: 'corp' }

    @bad_cards_asa_group = { identity_card_id: 'asa_group', side_id: 'corp', cards: { 'foo': 3, 'bar': 3 } }
    @too_few_cards_asa_group = { identity_card_id: 'asa_group', side_id: 'corp', cards: { 'hedge_fund': 3 } }

    @not_enough_agenda_points_45_card = { identity_card_id: 'asa_group', side_id: 'corp', cards: { 'hedge_fund': 36, 'project_vitruvius': 9 } }

    @too_much_influence_asa_group = {
      identity_card_id: 'asa_group',
      side_id: 'corp',
      cards: {
        'ikawah_project': 3,
        'project_vitruvius': 3,
        'send_a_message': 2,
        'regolith_mining_license': 3,
        'spin_doctor': 3,
        'trieste_model_bioroids': 3,
        'biotic_labor': 3,
        'hedge_fund': 3,
        'punitive_counterstrike': 3,
        'funhouse': 3,
        'hagen': 3,
        'hakarl_1_0': 3,
        'enigma': 3,
        'tollbooth': 3,
        'ansel_1_0': 3,
        'rototurret': 3,
        'tyr': 2,
      }
    }

    @good_asa_group = {
      identity_card_id: 'asa_group',
      side_id: 'corp',
      cards: {
        'ikawah_project': 3,
        'project_vitruvius': 3,
        'send_a_message': 2,
        'regolith_mining_license': 3,
        'spin_doctor': 3,
        'trieste_model_bioroids': 3,
        'biotic_labor': 3,
        'hedge_fund': 3,
        'punitive_counterstrike': 3,
        'eli_1_0': 3,
        'hagen': 3,
        'hakarl_1_0': 3,
        'enigma': 3,
        'tollbooth': 3,
        'ansel_1_0': 3,
        'rototurret': 3,
        'tyr': 2,
      }
    }
    @good_geist = { identity_card_id: 'geist', side_id: 'runner', cards: { 'sure_gamble': 45 } }
    @good_ken = {
      identity_card_id: 'ken_express_tenma_disappeared_clone',
      side_id: 'runner',
      cards: {
        'bravado': 3,
        'carpe_diem': 3,
        'dirty_laundry': 3,
        'embezzle': 2,
        'inside_job': 2,
        'legwork': 1,
        'marathon': 2,
        'mutual_favor': 2,
        'networking': 1,
        'sure_gamble': 3,
        'boomerang': 2,
        'buffer_drive': 1,
        'ghosttongue': 1,
        'pennyshaver': 2,
        'wake_implant_v2a_jrj': 1,
        'aeneas_informant': 3,
        'daily_casts': 3,
        'dreamnet': 1,
        'the_class_act': 2,
        'aumakua': 1,
        'bukhgalter': 1,
        'cats_cradle': 1,
        'paperclip': 1,
        'bankroll': 3,
      }
    }
  end

  def test_empty_deck_json
    v = DeckValidator.new()
    assert !v.validate(@empty_deck), 'Empty Deck JSON fails validation'
    assert_includes v.errors, "Deck is missing `identity_card_id` field."
    assert_includes v.errors, "Deck is missing `side_id` field."
  end

  def test_missing_identity
    v = DeckValidator.new()
    assert !v.validate(@missing_identity), 'Deck JSON missing identity fails validation'
    assert_includes v.errors, "Deck is missing `identity_card_id` field."
  end

  def test_missing_side
    v = DeckValidator.new()
    assert !v.validate(@missing_side), 'Deck JSON missing side fails validation'
    assert_includes v.errors, "Deck is missing `side_id` field."
  end

  def test_imaginary_identity
    v = DeckValidator.new()
    assert !v.validate(@imaginary_identity), 'Deck JSON has non-existent Identity'
    assert_includes v.errors, "`identity_card_id` `plural` does not exist."
  end

  def test_imaginary_side
    v = DeckValidator.new()
    assert !v.validate(@imaginary_side), 'Deck JSON has non-existent side'
    assert_includes v.errors, "`side_id` `super_mega_corp` does not exist."
  end

  def test_mismatched_side_corp_id
    v = DeckValidator.new()
    assert !v.validate(@wrong_side_asa_group), 'Deck with mismatched id and specified side fails'
    assert_includes v.errors, "Identity `asa_group` has side `corp` which does not match given side `runner`"
  end

  def test_mismatched_side_runner_id
    v = DeckValidator.new()
    assert !v.validate(@wrong_side_geist), 'Deck with mismatched id and specified side fails'
    assert_includes v.errors, "Identity `geist` has side `runner` which does not match given side `corp`"
  end

  def test_not_enough_agenda_points
    v = DeckValidator.new()
    assert !v.validate(@not_enough_agenda_points_45_card)
    assert_includes v.errors, "Deck with size 45 requires [20,21] agenda points, but deck only has 18"
  end

  def test_corp_too_much_influence
    v = DeckValidator.new()
    assert !v.validate(@too_much_influence_asa_group)
    assert_includes v.errors, "Influence limit for Asa Group: Security Through Vigilance is 15, but deck has spent 21 influence"
  end

  def test_good_corp_side
    v = DeckValidator.new()
    assert v.validate(@good_asa_group)
    assert_equal 0, v.errors.size
  end

  def test_good_runner_side
    v = DeckValidator.new()
    assert v.validate(@good_ken)
    assert_equal 0, v.errors.size
  end

  def test_bad_cards
    v = DeckValidator.new()
    assert !v.validate(@bad_cards_asa_group)
    assert_includes v.errors, "Card `foo` does not exist."
    assert_includes v.errors, "Card `bar` does not exist."
  end

  def test_too_few_cards
    v = DeckValidator.new()
    assert !v.validate(@too_few_cards_asa_group)
    assert_includes v.errors, "Minimum deck size is 45, but deck has 3 cards."
  end
end
