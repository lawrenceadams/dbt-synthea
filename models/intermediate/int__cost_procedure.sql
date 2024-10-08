SELECT DISTINCT
    po.procedure_occurrence_id AS cost_event_id
    , 'Procedure' AS cost_domain_id
    , 32814 AS cost_type_concept_id
    , 44818668 AS currency_concept_id
    , {{ dbt.cast("e.total_encounter_cost", api.Column.translate_type("decimal")) }} + {{ dbt.cast("pr.procedure_base_cost", api.Column.translate_type("decimal")) }} AS total_charge
    , {{ dbt.cast("e.total_encounter_cost", api.Column.translate_type("decimal")) }} + {{ dbt.cast("pr.procedure_base_cost", api.Column.translate_type("decimal")) }} AS total_cost
    , {{ dbt.cast("e.encounter_payer_coverage", api.Column.translate_type("decimal")) }} + {{ dbt.cast("pr.procedure_base_cost", api.Column.translate_type("decimal")) }} AS total_paid
    , e.encounter_payer_coverage AS paid_by_payer
    , {{ dbt.cast("e.total_encounter_cost", api.Column.translate_type("decimal")) }}
    + {{ dbt.cast("pr.procedure_base_cost", api.Column.translate_type("decimal")) }}
    - {{ dbt.cast("e.encounter_payer_coverage", api.Column.translate_type("decimal")) }} AS paid_by_patient
    , cast(null AS numeric) AS paid_patient_copay
    , cast(null AS numeric) AS paid_patient_coinsurance
    , cast(null AS numeric) AS paid_patient_deductible
    , cast(null AS numeric) AS paid_by_primary
    , cast(null AS numeric) AS paid_ingredient_cost
    , cast(null AS numeric) AS paid_dispensing_fee
    , ppp.payer_plan_period_id
    , cast(null AS numeric) AS amount_allowed
    , 0 AS revenue_code_concept_id
    , 'UNKNOWN / UNKNOWN' AS revenue_code_source_value
    , 0 AS drg_concept_id
    , '000' AS drg_source_value
FROM {{ ref ('stg_synthea__procedures') }} AS pr
INNER JOIN {{ ref ('stg_synthea__encounters') }} AS e
    ON
        pr.encounter_id = e.encounter_id
        AND pr.patient_id = e.patient_id
INNER JOIN {{ ref ('person') }} AS p
    ON pr.patient_id = p.person_source_value
INNER JOIN
    {{ ref ('visit_occurrence') }}
    AS vo
    ON
        p.person_id = vo.person_id
        AND e.encounter_id = vo.visit_source_value
INNER JOIN {{ ref ('procedure_occurrence') }} AS po
    ON
        pr.procedure_code = po.procedure_source_value
        AND vo.visit_occurrence_id = po.visit_occurrence_id
        AND vo.person_id = po.person_id
LEFT JOIN {{ ref ('payer_plan_period') }} AS ppp
    ON
        p.person_id = ppp.person_id
        AND po.procedure_date >= ppp.payer_plan_period_start_date
        AND po.procedure_date <= ppp.payer_plan_period_end_date
