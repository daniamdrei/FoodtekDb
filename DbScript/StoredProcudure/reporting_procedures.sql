DELIMITER //

-- Get sales report by restaurant
CREATE PROCEDURE sp_GetRestaurantSalesReport(
    IN p_restaurant_id BIGINT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        r.name AS restaurant_name,
        COUNT(o.id) AS total_orders,
        SUM(o.total_price) AS total_revenue,
        AVG(o.total_price) AS average_order_value,
        COUNT(DISTINCT o.user_id) AS unique_customers
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN food_items f ON oi.food_item_id = f.id
    JOIN categories c ON f.category_id = c.id
    JOIN restaurants r ON c.restaurant_id = r.id
    WHERE r.id = p_restaurant_id
    AND o.created_at BETWEEN p_start_date AND DATE_ADD(p_end_date, INTERVAL 1 DAY)
    GROUP BY r.name;
    
    -- Top selling items
    SELECT 
        f.name AS item_name,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.price) AS total_revenue
    FROM order_items oi
    JOIN food_items f ON oi.food_item_id = f.id
    JOIN categories c ON f.category_id = c.id
    WHERE c.restaurant_id = p_restaurant_id
    AND oi.created_at BETWEEN p_start_date AND DATE_ADD(p_end_date, INTERVAL 1 DAY)
    GROUP BY f.name
    ORDER BY total_quantity DESC
    LIMIT 10;
END //

DELIMITER ;