CREATE TABLE tenants (
    tenant_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(15),

    CONSTRAINT fk_user_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_user_email
        UNIQUE (tenant_id, email)
);
CREATE TABLE categories (
    category_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    category_name VARCHAR(100) NOT NULL,

    CONSTRAINT fk_category_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_category
        UNIQUE (tenant_id, category_name)
);
CREATE TABLE products (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),

    CONSTRAINT fk_product_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);
CREATE TABLE orders (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(20) DEFAULT 'PENDING',

    CONSTRAINT fk_order_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_order_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT chk_order_status
        CHECK (
            order_status IN
            ('PENDING','PAID','SHIPPED','DELIVERED','CANCELLED')
        )
);
CREATE TABLE order_items (
    order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),

    -- Deliberate denormalization
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),

    CONSTRAINT fk_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_item_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT uq_order_product
        UNIQUE (order_id, product_id)
);
CREATE TABLE reviews (
    review_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_review_tenant
        FOREIGN KEY (tenant_id)
        REFERENCES tenants(tenant_id),

    CONSTRAINT fk_review_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_review_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT uq_user_product_review
        UNIQUE (user_id, product_id)
);
INSERT INTO tenants (tenant_name, email)
VALUES
('Tech Store', 'techstore@gmail.com'),
('Fashion Hub', 'fashionhub@gmail.com');
INSERT INTO users (tenant_id, user_name, email, phone)
VALUES
(1, 'Ravi Kumar', 'ravi@gmail.com', '9876543210'),
(1, 'Suresh', 'suresh@gmail.com', '9876543211'),
(2, 'Anjali', 'anjali@gmail.com', '9876543212');
INSERT INTO categories (tenant_id, category_name)
VALUES
(1, 'Laptops'),
(1, 'Mobiles'),
(2, 'Men Clothing'),
(2, 'Women Clothing');
INSERT INTO products
(tenant_id, category_id, product_name, price, stock_quantity)
VALUES
(1, 1, 'Dell Laptop', 65000, 10),
(1, 2, 'Samsung Mobile', 30000, 20),
(2, 3, 'Formal Shirt', 1500, 50),
(2, 4, 'Women Dress', 3000, 25);
INSERT INTO orders
(tenant_id, user_id, order_status)
VALUES
(1, 1, 'PAID'),
(1, 2, 'SHIPPED'),
(2, 3, 'DELIVERED');
INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 65000),
(1, 2, 2, 30000),
(2, 2, 1, 30000),
(3, 3, 2, 1500);
INSERT INTO reviews
(tenant_id, user_id, product_id, rating, review_text)
VALUES
(1, 1, 1, 5, 'Excellent Laptop'),
(1, 2, 2, 4, 'Good Mobile'),
(2, 3, 3, 5, 'Very Good Shirt');
SELECT *FROM products;
SELECT product_name, price
FROM products
WHERE tenant_id = 1;
SELECT
    order_id,
    SUM(quantity * unit_price) AS total_amount
FROM order_items
GROUP BY order_id;
SELECT
    o.order_id,
    u.user_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS amount
FROM orders o

JOIN users u
ON o.user_id = u.user_id

JOIN order_items oi
ON o.order_id = oi.order_id

JOIN products p
ON oi.product_id = p.product_id;
SELECT
    p.product_name,
    AVG(r.rating) AS average_rating
FROM products p

JOIN reviews r
ON p.product_id = r.product_id

GROUP BY p.product_id, p.product_name;

SELECT DISTINCT
    u.user_id,
    u.user_name
FROM users u
JOIN orders o
ON u.user_id = o.user_id;

update reviews set review_text='very gud' where tenant_id = 2
  AND user_id = 3
  AND product_id = 3;