/* 注文データの抽出 */
WITH orders_subset AS (
    SELECT
        order_id
        , product_id
        , user_id
        , referrer
        , order_datetime
        , coupon_id
    FROM orders
)

/* 返品データの抽出 */
, return_item_subset AS (
    SELECT
        order_id
        , product_id
        , user_id
        , return_datetime
    FROM return_item
)

/* 商品マスタの抽出 */
, product_subset AS (
    SELECT
        product_id
        , product_name
        , category_id
        , brand
        , price
        , color
        , weight
        , size
    FROM product
)

/* カテゴリーマスタの抽出 */
, category_subset AS (
    SELECT
        category_id
        , category_name
    FROM category
)

/* クーポンマスタの抽出 */
, coupon_subset AS (
    SELECT
        coupon_id
        , product_id
        , coupon_amount
    FROM coupon
)

/* 返品のあった注文商品を除外 */
, filtered_orders AS (
    SELECT
        os.order_id
        , os.product_id
        , os.user_id
        , os.referrer
        , os.order_datetime
        , os.coupon_id
    FROM orders_subset AS os
    LEFT JOIN return_item_subset AS rs
        ON os.order_id = rs.order_id
        AND os.product_id = rs.product_id
        AND os.user_id = rs.user_id
    WHERE
        rs.order_id IS NULL
        AND rs.product_id IS NULL
)

/* 注文商品に商品とカテゴリの情報を付与 */
, orders_with_product_info AS (
    SELECT
        fo.order_id
        , fo.product_id
        , fo.user_id
        , fo.referrer
        , ps.product_name
        , ps.brand
        , ps.price
        , ps.color
        , ps.weight
        , ps.size
        , fo.order_datetime
        , fo.coupon_id
        , cs.category_name
    FROM filtered_orders AS fo
    LEFT JOIN product_subset AS ps
        ON fo.product_id = ps.product_id
    LEFT JOIN category_subset AS cs
        ON ps.category_id = cs.category_id
)

/* 注文商品にクーポンの情報を付与して割引後金額を計算 */
, orders_with_discounts AS (
    SELECT
        op.order_id
        , op.user_id
        , op.referrer
        , op.product_id
        , op.product_name
        , op.brand
        , op.price
        , cs.coupon_amount
        , op.price - cs.coupon_amount AS discounted_price
        , op.color
        , op.weight
        , op.size
        , op.order_datetime
        , op.coupon_id
        , op.category_name
    FROM orders_with_product_info AS op
    LEFT JOIN coupon_subset AS cs
        ON op.coupon_id = cs.coupon_id
        AND op.produt_id = cs.procut_id
)

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
FROM orders_with_discounts