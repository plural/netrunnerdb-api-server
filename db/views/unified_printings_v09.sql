WITH
card_cycles_summary AS (
    SELECT
        c.id,
        ARRAY_AGG(
            cc.id ORDER BY cc.date_release DESC
        ) as card_cycle_ids,
        ARRAY_AGG(
            cc.name ORDER BY cc.date_release DESC
        ) as card_cycle_names
    FROM
        cards c
        JOIN printings p ON c.id = p.card_id
        JOIN card_sets cs ON p.card_set_id = cs.id
        JOIN card_cycles cc ON cc.id = cs.card_cycle_id
    GROUP BY
        c.id
),
card_sets_summary AS (
    SELECT
        c.id,
        ARRAY_AGG(
            cs.id ORDER BY cs.date_release DESC
        ) as card_set_ids,
        ARRAY_AGG(
            cs.name ORDER BY cs.date_release DESC
        ) as card_set_names
    FROM
        cards c
        JOIN printings p ON c.id = p.card_id
        JOIN card_sets cs ON p.card_set_id = cs.id
    GROUP BY
        c.id
),
card_subtype_ids AS (
    SELECT
        card_id,
        ARRAY_AGG(card_subtype_id ORDER BY 1) as card_subtype_ids
    FROM
        cards_card_subtypes
    GROUP BY
        card_id
),
card_subtype_names AS (
    SELECT
        ccs.card_id,
        -- lower used for filtering
        ARRAY_AGG(LOWER(cs.name) ORDER BY LOWER(cs.name)) as lower_card_subtype_names,
        -- proper case used for display
        ARRAY_AGG(
            cs.name ORDER BY cs.name
        ) as card_subtype_names
    FROM
        cards_card_subtypes ccs
        JOIN card_subtypes cs ON ccs.card_subtype_id = cs.id
    GROUP BY
        ccs.card_id
),
card_printing_ids AS (
    SELECT
        card_id,
        ARRAY_AGG(id ORDER BY date_release DESC) as printing_ids
    FROM
        printings
    GROUP BY
        card_id
),
printing_releasers AS (
    SELECT
        card_id,
        ARRAY_AGG(DISTINCT released_by ORDER BY released_by) as releasers
    FROM
        printings
    GROUP BY
        card_id
),
illustrators AS (
    SELECT
        ip.printing_id,
        ARRAY_AGG(ip.illustrator_id ORDER BY ip.illustrator_id) as illustrator_ids,
        ARRAY_AGG(i.name ORDER BY i.name) as illustrator_names
    FROM
        illustrators_printings ip JOIN illustrators i ON ip.illustrator_id = i.id
    GROUP BY
        ip.printing_id
),
card_restriction_ids AS (
    SELECT
        card_id,
        ARRAY_AGG(
            restriction_id ORDER BY restriction_id
        ) as restriction_ids
    FROM
        unified_restrictions
    WHERE
        in_restriction
    GROUP BY
        1
),
restrictions_banned_summary AS (
    SELECT
        card_id,
        ARRAY_AGG(
            restriction_id ORDER BY restriction_id
        ) as restrictions_banned
    FROM
        restrictions_cards_banned
    GROUP BY
        card_id
),
restrictions_global_penalty_summary AS (
    SELECT
        card_id,
        ARRAY_AGG(
            restriction_id ORDER BY restriction_id
        ) as restrictions_global_penalty
    FROM
        restrictions_cards_global_penalty
    GROUP BY
        card_id
),
restrictions_points_summary AS (
    SELECT
        card_id,
        ARRAY_AGG(
            CONCAT(restriction_id, '=', CAST (value AS text))
            ORDER BY CONCAT(restriction_id, '=', CAST (value AS text))
        ) as restrictions_points
    FROM
        restrictions_cards_points
    GROUP BY
        card_id
),
restrictions_restricted_summary AS (
    SELECT
        card_id,
        ARRAY_AGG(
            restriction_id ORDER BY restriction_id
        ) as restrictions_restricted
    FROM
        restrictions_cards_restricted
    GROUP BY
        card_id
),
restrictions_universal_faction_cost_summary AS (
    SELECT
        card_id,
        ARRAY_AGG(
            CONCAT(restriction_id, '=', CAST (value AS text))
            ORDER BY CONCAT(restriction_id, '=', CAST (value AS text))
        ) as restrictions_universal_faction_cost
    FROM
        restrictions_cards_universal_faction_cost
    GROUP BY
        card_id
),
format_ids AS (
    SELECT
        cpc.card_id,
        ARRAY_AGG(
            DISTINCT s.format_id ORDER BY s.format_id
        ) as format_ids
    FROM
        card_pools_cards cpc
        JOIN snapshots s ON cpc.card_pool_id = s.card_pool_id
    GROUP BY
        cpc.card_id
),
card_pool_ids AS (
    SELECT
        cpc.card_id,
        ARRAY_AGG(
            DISTINCT s.card_pool_id ORDER BY s.card_pool_id
        ) as card_pool_ids
    FROM
        card_pools_cards cpc
        JOIN snapshots s ON cpc.card_pool_id = s.card_pool_id
    GROUP BY
        cpc.card_id
),
snapshot_ids AS (
    SELECT
        cpc.card_id,
        ARRAY_AGG(
            DISTINCT s.id ORDER BY s.id
        ) as snapshot_ids
    FROM
        card_pools_cards cpc
        JOIN snapshots s ON cpc.card_pool_id = s.card_pool_id
    GROUP BY
        cpc.card_id
)
SELECT
    p.id,
    p.card_id,
    cc.id as card_cycle_id,
    cc.name as card_cycle_name,
    p.card_set_id,
    cs.name as card_set_name,
    p.flavor,
    p.display_illustrators,
    p.position,
    p.position_in_set,
    p.quantity,
    p.date_release,
    p.created_at,
    p.updated_at,
    c.additional_cost,
    c.advanceable,
    c.advancement_requirement,
    c.agenda_points,
    c.base_link,
    c.card_type_id,
    c.cost,
    c.faction_id,
    c.gains_subroutines,
    c.influence_cost,
    c.interrupt,
    c.is_unique,
    c.link_provided,
    c.memory_cost,
    c.mu_provided,
    c.num_printed_subroutines,
    c.on_encounter_effect,
    c.performs_trace,
    c.pronouns,
    c.pronunciation_approximation,
    c.pronunciation_ipa,
    c.recurring_credits_provided,
    c.side_id,
    c.strength,
    c.stripped_text,
    c.stripped_title,
    c.trash_ability,
    c.trash_cost,
    COALESCE(csi.card_subtype_ids, ARRAY [] :: text []) as card_subtype_ids,
    COALESCE(csn.lower_card_subtype_names, ARRAY [] :: text []) as lower_card_subtype_names,
    COALESCE(csn.card_subtype_names, ARRAY [] :: text []) as card_subtype_names,
    cp.printing_ids,
    p.id = cp.printing_ids[1] AS is_latest_printing,
    ARRAY_LENGTH(cp.printing_ids, 1) AS num_printings,
    COALESCE(ccs.card_cycle_ids, ARRAY [] :: text []) as card_cycle_ids,
    COALESCE(ccs.card_cycle_names, ARRAY [] :: text []) as card_cycle_names,
    COALESCE(css.card_set_ids, ARRAY [] :: text []) as card_set_ids,
    COALESCE(css.card_set_names, ARRAY [] :: text []) as card_set_names,
    COALESCE(i.illustrator_ids, ARRAY [] :: text []) as illustrator_ids,
    COALESCE(i.illustrator_names, ARRAY [] :: text []) as illustrator_names,
    COALESCE(r.restriction_ids, ARRAY [] :: text []) as restriction_ids,
    r.restriction_ids IS NOT NULL as in_restriction,
    COALESCE(r_b.restrictions_banned, ARRAY [] :: text []) as restrictions_banned,
    COALESCE(r_g_p.restrictions_global_penalty, ARRAY [] :: text []) as restrictions_global_penalty,
    COALESCE(r_p.restrictions_points, ARRAY [] :: text []) as restrictions_points,
    COALESCE(r_r.restrictions_restricted, ARRAY [] :: text []) as restrictions_restricted,
    COALESCE(r_u_f_c.restrictions_universal_faction_cost, ARRAY [] :: text []) as restrictions_universal_faction_cost,
    COALESCE(f.format_ids, ARRAY [] :: text []) as format_ids,
    COALESCE(cpc.card_pool_ids, ARRAY [] :: text []) as card_pool_ids,
    COALESCE(s.snapshot_ids, ARRAY [] :: text []) as snapshot_ids,
    c.attribution,
    c.deck_limit,
    c.display_subtypes,
    c.influence_limit,
    c.minimum_deck_size,
    c.rez_effect,
    c.text,
    c.title,
    c.designed_by,
    p.released_by,
    pr.releasers as printings_released_by
FROM
    printings p
    INNER JOIN cards c ON p.card_id = c.id
    JOIN card_cycles_summary ccs ON c.id = ccs.id
    JOIN card_sets_summary css ON c.id = css.id
    INNER JOIN card_sets cs ON p.card_set_id = cs.id
    INNER JOIN card_cycles cc ON cs.card_cycle_id = cc.id
    LEFT JOIN card_subtype_ids csi ON c.id = csi.card_id
    LEFT JOIN card_subtype_names csn ON c.id = csn.card_id
    INNER JOIN card_printing_ids cp ON p.card_id = cp.card_id
    INNER JOIN printing_releasers pr ON p.card_id = pr.card_id
    LEFT JOIN illustrators i ON p.id = i.printing_id
    LEFT JOIN card_restriction_ids r ON p.card_id = r.card_id
    LEFT JOIN restrictions_banned_summary r_b ON p.card_id = r_b.card_id
    LEFT JOIN restrictions_global_penalty_summary r_g_p ON p.card_id = r_g_p.card_id
    LEFT JOIN restrictions_points_summary r_p ON p.card_id = r_p.card_id
    LEFT JOIN restrictions_restricted_summary r_r ON p.card_id = r_r.card_id
    LEFT JOIN restrictions_universal_faction_cost_summary r_u_f_c ON p.card_id = r_u_f_c.card_id
    LEFT JOIN format_ids f ON p.card_id = f.card_id
    LEFT JOIN card_pool_ids cpc ON p.card_id = cpc.card_id
    LEFT JOIN snapshot_ids s ON p.card_id = s.card_id
;
