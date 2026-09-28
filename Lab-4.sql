CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT extname
FROM pg_extension
WHERE extname = 'pg_stat_statements';
CREATE TABLE customers
(
    customer_id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE products
(
    product_id BIGSERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0
);

CREATE TABLE orders
(
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(30),
    total_amount NUMERIC(12,2),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

CREATE TABLE order_items
(
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

INSERT INTO customers
(
    customer_name,
    email,
    city,
    state,
    created_at
)
SELECT
    'Customer_' || g,

    'customer' || g || '@datavault.com',

    CASE
        WHEN g % 10 = 0 THEN 'Hyderabad'
        WHEN g % 10 = 1 THEN 'Vijayawada'
        WHEN g % 10 = 2 THEN 'Guntur'
        WHEN g % 10 = 3 THEN 'Chennai'
        WHEN g % 10 = 4 THEN 'Bangalore'
        WHEN g % 10 = 5 THEN 'Mumbai'
        WHEN g % 10 = 6 THEN 'Delhi'
        WHEN g % 10 = 7 THEN 'Pune'
        WHEN g % 10 = 8 THEN 'Kolkata'
        ELSE 'Visakhapatnam'
    END,

    CASE
        WHEN g % 5 = 0 THEN 'Andhra Pradesh'
        WHEN g % 5 = 1 THEN 'Telangana'
        WHEN g % 5 = 2 THEN 'Tamil Nadu'
        WHEN g % 5 = 3 THEN 'Karnataka'
        ELSE 'Maharashtra'
    END,

    CURRENT_TIMESTAMP
        - (random() * INTERVAL '1000 days')

FROM generate_series(1,100000) AS g;
SELECT COUNT(*)
FROM customers;
INSERT INTO products
(
    product_name,
    category,
    price,
    stock_quantity
)
SELECT
    'Product_' || g,

    CASE
        WHEN g % 8 = 0 THEN 'Electronics'
        WHEN g % 8 = 1 THEN 'Computers'
        WHEN g % 8 = 2 THEN 'Mobiles'
        WHEN g % 8 = 3 THEN 'Books'
        WHEN g % 8 = 4 THEN 'Clothing'
        WHEN g % 8 = 5 THEN 'Furniture'
        WHEN g % 8 = 6 THEN 'Sports'
        ELSE 'Home Appliances'
    END,

    ROUND((100 + random() * 50000)::NUMERIC, 2),

    (random() * 1000)::INTEGER

FROM generate_series(1,10000) AS g;
SELECT COUNT(*)
FROM products;

INSERT INTO orders
(
    customer_id,
    order_date,
    order_status,
    total_amount
)
SELECT
    1 + (random() * 99999)::BIGINT,

    CURRENT_DATE
        - (random() * 1000)::INTEGER,

    CASE
        WHEN g % 5 = 0 THEN 'Pending'
        WHEN g % 5 = 1 THEN 'Processing'
        WHEN g % 5 = 2 THEN 'Shipped'
        WHEN g % 5 = 3 THEN 'Delivered'
        ELSE 'Cancelled'
    END,

    ROUND((100 + random() * 100000)::NUMERIC, 2)

FROM generate_series(1,1000000) AS g;

SELECT COUNT(*)
FROM orders;

INSERT INTO order_items
(
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    1 + (random() * 999999)::BIGINT,

    1 + (random() * 9999)::BIGINT,

    1 + (random() * 10)::INTEGER,

    ROUND((100 + random() * 50000)::NUMERIC, 2)

FROM generate_series(1,2000000) AS g;
SELECT COUNT(*)
FROM order_items;

ANALYZE customers;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;
SELECT
    relname AS table_name,
    n_live_tup AS estimated_rows
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;

SELECT pg_stat_statements_reset();
SHOW shared_preload_libraries;

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
