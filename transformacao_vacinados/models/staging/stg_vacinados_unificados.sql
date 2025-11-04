select
    *,
    '2022' as ano_origem 

from {{ source('dados_brutos_recife', 'raw_vacinados_2022') }}

union all

select
    *,
    '2023' as ano_origem
from {{ source('dados_brutos_recife', 'raw_vacinados_2023') }}

union all

select
    *,
    '2024' as ano_origem
from {{ source('dados_brutos_recife', 'raw_vacinados_2024') }}