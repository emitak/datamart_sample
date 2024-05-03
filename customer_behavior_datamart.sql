/* 顧客マスタの抽出 */
WITH user_subset AS (
    SELECT
        user_id
        , register_datetime
    FROM user_table
)

/* アプリ内行動ログの抽出 */
/*
    1:ログイン
    2:検索
    3:カート追加
    4:支払い
*/
, app_behavior_subset AS (
    SELECT
        user_id
        , behavior_id
        , created_datetime
    FROM app_behavior
)

/*
顧客マスタと行動ログを結合して、
行動ログを横持ちにフラグ立てする
*/
, add_behavior_flag AS (
    SELECT
        us.user_id
        , MIN(us.register_datetime) AS register_datetime
        --ログイン〜支払いまでの到達をフラグ化
        , MAX(
            CASE
                WHEN ab.behavior_id = 1 ab.created_datetime IN NOT NULL
                    THEN 1
                ELSE 0
            END
        ) AS log_in_flag
        , MAX(
            CASE
                WHEN ab.behavior_id = 2 ab.created_datetime IN NOT NULL
                    THEN 1
                ELSE 0
            END
        ) AS search_flag
        , MAX(
            CASE
                WHEN ab.behavior_id = 3 ab.created_datetime IN NOT NULL
                    THEN 1
                ELSE 0
            END
        ) AS add_cart_flag
        , MAX(
            CASE
                WHEN ab.behavior_id = 4 ab.created_datetime IN NOT NULL
                    THEN 1
                ELSE 0
            END
        ) AS payment_flag
        --ログイン〜支払いの日時を横持ち
        , MIN(
            CASE
                WHEN ab.behavior_id = 1
                    THEN ab.created_datetime
                ELSE NULL
            END
        ) AS log_in_datetime
        , MIN(
            CASE
                WHEN ab.behavior_id = 2
                    THEN ab.created_datetime
                ELSE NULL
            END
        ) AS search_datetime
        , MIN(
            CASE
                WHEN ab.behavior_id = 3
                    THEN ab.created_datetime
                ELSE NULL
            END
        ) AS add_cart_datetime
        , MIN(
            CASE
                WHEN ab.behavior_id = 4
                    THEN ab.created_datetime
                ELSE NULL
            END
        ) AS payment_datetime
    FROM user_subset AS us
    LEFT JOIN app_behavior_subset AS ab
        ON us.user_id = ab.user_id
    GROUP BY
        us.user_id
)

SELECT
    user_id
    , register_datetime
    , log_in_flag
    , search_flag
    , add_cart_flag
    , payment_flag
    , log_in_datetime
    , search_datetime
    , add_cart_datetime
    , payment_datetime
FROM add_behavior_flag
