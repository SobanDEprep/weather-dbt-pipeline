{% snapshot snapshot_weather_conditions %}

{{
    config(
        target_schema='STAGING',
        unique_key='code',
        strategy='check',
        check_cols=['description', 'category']
    )
}}

select * from {{ ref('weather_codes') }}

{% endsnapshot %}