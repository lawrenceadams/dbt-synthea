-- Returns a list of the columns from a relation, so you can then iterate in a for loop
{% set column_names = 
    dbt_utils.get_filtered_columns_in_relation( source('synthea', 'claims_transactions') ) 
%}


WITH cte_claims_transactions_lower AS (

    SELECT  

        {% for column_name in column_names %}
            "{{ column_name }}" as {{ column_name | lower }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
        
    FROM {{ source('synthea','claims_transactions') }}
) 

, cte_claims_transactions_rename AS (

    SELECT 
        id AS claim_transaction_id,
        claimid AS claim_id,
        chargeid AS charge_id,
        patientid AS patient_id,
        "type" AS transaction_type,
        amount AS transaction_amount,
        method AS transaction_method,
        fromdate AS transaction_from_date,
        todate AS transaction_to_date,
        placeofservice AS place_of_service,
        procedurecode AS procedure_code,
        modifier1 AS procedure_code_modifier1,
        modifier2 AS procedure_code_modifier2,
        diagnosisref1 AS claim_diagnosis_ref1,
        diagnosisref2 AS claim_diagnosis_ref2,
        diagnosisref3 AS claim_diagnosis_ref3,
        diagnosisref4 AS claim_diagnosis_ref4,
        units AS service_units,
        departmentid AS department_id,
        notes AS transaction_notes,
        unitamount AS per_unit_amount,
        transferoutid AS transfer_out_id,
        transfertype AS transfer_type,
        payments AS payments,
        adjustments AS adjustments,
        transfers AS transfers,
        outstanding AS outstanding,
        appointmentid AS encounter_id,
        linenote AS claim_transaction_line_note,
        patientinsuranceid AS patient_insurance_id,
        feescheduleid AS fee_schedule_id,
        providerid AS provider_id,
        supervisingproviderid AS supervising_provider_id
    FROM cte_claims_transactions_lower

)

SELECT  * 
FROM cte_claims_transactions_rename