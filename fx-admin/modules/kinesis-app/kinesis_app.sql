CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM"
("buyer" VARCHAR(100),
"seller" VARCHAR(100),
"primary_node_namespace" VARCHAR(100),
"secondary_node_namespace" VARCHAR(100),
"trade_ref_id" VARCHAR(100),
"type" VARCHAR(100),
"trml_version" VARCHAR(100),
"trade_date" VARCHAR(100),
"product" VARCHAR(100),
"traded_amount_near" DOUBLE,
"secondary_amount_near" DOUBLE,
"value_date_near" VARCHAR(100),
"buyer_asset_type" VARCHAR(100),
"seller_asset_type" VARCHAR(100),
"record_type" VARCHAR(100),
"process" varchar(100),
"trade_group" varchar(100),
"buy_trade_id" varchar(100),
"sell_trade_id" varchar(100),
"buyer_ticket_num" varchar(100),
"seller_ticket_num" varchar(100),
"normalized_evt_id" varchar(1000),
"message_type" varchar(1000),
"leg" varchar(1000),
"baton_match_time" timestamp);
CREATE OR REPLACE PUMP "ORDER_ID_MATCHING_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
SELECT STREAM
b."primary_node",
b."secondary_node",
b."primary_node_namespace",
b."secondary_node_namespace",
b."id",
b."type",
b."trml_version",
b."trade_date",
b."product",
b."traded_amount_near",
b."secondary_amount_near",
b."value_date_near",
b."primary_asset_type",
b."secondary_asset_type",
'MATCHED_ORDER',
b."process",
b."trade_group",
b."trade_id",
s."trade_id",
b."ticket_num",
s."ticket_num",
b."normalized_evt_id",
b."message_type",
b."leg",
ROWTIME
FROM "SOURCE_SQL_STREAM_001" over t as b
JOIN "SOURCE_SQL_STREAM_001" over t as s
ON ( b."normalized_evt_id" = s."normalized_evt_id" and
b."process" = s."process" and
b."message_type"=s."message_type" and
b."record_type"='BUY' and s."record_type"='SELL')
WINDOW t AS
(RANGE INTERVAL '10' MINUTE PRECEDING);
/*WINDOWED BY STAGGER (
PARTITION BY FLOOR(b.ROWTIME TO MINUTE),
b."type",
b."trml_version",
b."primary_node",
b."secondary_node",
b."primary_node_namespace",
b."secondary_node_namespace",
b."trade_date",
b."product",
b."primary_asset_type",
b."traded_amount_near",
b."value_date_near",
b."secondary_asset_type",
b."record_type",
b."id",
b."secondary_amount_near",
b."process",
b."trade_group",
b."trade_id",
b."ticket_num",
b."matching_time",
b."normalized_evt_id",
b."message_type",
b."leg",
s."trade_id",
s."ticket_num"
--s."record_type",
--s."process",
--s."normalized_evt_id"
RANGE INTERVAL '1' MINUTE)
;*/