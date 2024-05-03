/* 注文ログの抽出 */
WITH order_sebset AS (
    SELECT
        order_id
        , user_id
        , user_type --1:新規、2:リピーター
        , order_datetime
        , campaign_id
        , total --注文合計金額
    FROM order
)

/* キャンペーンマスタの抽出 */
, campaign_subset AS (
    SELECT
        campaign_id
        , campaign_name
        , campaign_start_date
        , campaign_end_date
        , campain_type
        , description
    FROM campaign
)

/* マーケティング情報の抽出 */
, marketing_data_subset AS (
    SELECT
        campaign_id
        , campaign_cost
        , marketing_cost
        , media_name
    FROM marketing_data
)

/* 注文ログをキャンペーンごとに集計 */
, aggregate_order_by_campaign_id AS (
    SELECT
        campaign_id
        , COUNT(DISTINCT order_id) AS count_order  --注文回数
        , SUM(total) AS total   --注文金額
        , COUNT(DISTINCT IF(user_type = 1, user_id, NULL)) AS count_new_user    --新規ユーザー数
        , COUNT(DISTINCT IF(user_type = 2, user_id, NULL)) AS count_repeat_user    --リピートユーザー数
    FROM order_sebset
    GROUP BY
        campaign_id
)

SELECT
    cs.campaign_id
    , cs.campaign_name
    , cs.campaign_start_date
    , cs.campaign_end_date
    , cs.campain_type
    , cs.description
    , ao.count_order
    , ao.total
    , ao.count_new_user
    , ao.count_repeat_user
    , ms.campaign_cost
    , ms.marketing_cost
    , ms.media_name
FROM campaign_subset AS cs
LEFT JOIN aggregate_order_by_campaign_id AS ao
    ON cs.campaign_id = ao.campaign_id
LEFT JOIN marketing_data_subset AS ms
    ON cs.campaign_id = ms.campaign_id
