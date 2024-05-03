/* 顧客マスタの抽出 */
WITH user_subset AS (
    SELECT
        user_id
        , area_name
        , age
        , gender
        , segment_name
    FROM user_table
)

/* 注文商品データマートの抽出 */
, order_item AS (
    SELECT
        order_id
        , user_id
        , referrer
        , product_id
        , product_name
        , brand
        , price
        , coupon_amount
        , discounted_price
        , color
        , weight
        , size
        , order_datetime
        , coupon_id
        , category_name
        --ユーザーごとの注文回数を採番
        , ROW_NUMBER() OVER(
            PARTITION BY user_id
            ORDER BY order_datetime
        ) AS order_num
    FROM order_item_datamart
)

/* 注文商品をユーザーごとに横持ちにする */
, pivot_order_item AS (
    SELECT
        user_id
        --1〜3回目の注文商品のID
        , CASE
            WHEN order_num = 1
                THEN LISTAGG(DISTINCT product_id, ', ')
            ELSE NULL
        END AS first_product_id
        , CASE
            WHEN order_num = 2
                THEN LISTAGG(DISTINCT product_id, ', ')
            ELSE NULL
        END AS second_product_id
        , CASE
            WHEN order_num = 3
                THEN LISTAGG(DISTINCT product_id, ', ')
            ELSE NULL
        END AS third_product_id
        --1〜3回目の注文商品名
        , CASE
            WHEN order_num = 1
                THEN LISTAGG(DISTINCT product_name, ', ')
            ELSE NULL
        END AS first_product_name
        , CASE
            WHEN order_num = 2
                THEN LISTAGG(DISTINCT product_name, ', ')
            ELSE NULL
        END AS second_product_name
        , CASE
            WHEN order_num = 3
                THEN LISTAGG(DISTINCT product_name, ', ')
            ELSE NULL
        END AS third_product_name
    FROM order_item
    GROUP BY
        user_id
)

/* 顧客属性のデータと注文商品のデータを結合する */
SELECT
    us.user_id
    , us.area_name
    , us.age
    , us.gender
    , us.segment_name
    , po.first_product_id
    , po.second_product_id
    , po.third_product_id
    , po.first_product_name
    , po.second_product_name
    , po.third_product_name
FROM user_subset AS us
LEFT JOIN pivot_order_item AS po
    ON us.user_id = po.user_id
