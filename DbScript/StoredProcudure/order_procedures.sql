DELIMITER //

-- Create new order from cart
CREATE PROCEDURE sp_CreateOrderFromCart(
    IN p_user_id BIGINT,
    IN p_address_id BIGINT,
    OUT p_order_id BIGINT,
    OUT p_total_price DECIMAL(8,2)
)
BEGIN
    DECLARE total DECIMAL(8,2) DEFAULT 0;
    
    -- Calculate total price
    SELECT SUM(f.price * c.quantity) INTO total
    FROM cart_items c
    JOIN food_items f ON c.food_item_id = f.id
    WHERE c.user_id = p_user_id;
    
    -- Create order
    INSERT INTO orders (user_id, status, total_price, payment_status, created_at, updated_at)
    VALUES (p_user_id, 'pending', total, 'unpaid', NOW(), NOW());
    
    SET p_order_id = LAST_INSERT_ID();
    SET p_total_price = total;
    
    -- Add order items
    INSERT INTO order_items (order_id, food_item_id, quantity, price, created_at, updated_at)
    SELECT p_order_id, c.food_item_id, c.quantity, f.price, NOW(), NOW()
    FROM cart_items c
    JOIN food_items f ON c.food_item_id = f.id
    WHERE c.user_id = p_user_id;
    
    -- Clear cart
    DELETE FROM cart_items WHERE user_id = p_user_id;
    
    -- Create delivery status
    INSERT INTO delivery_statuses (order_id, status, created_at, updated_at)
    VALUES (p_order_id, 'pending', NOW(), NOW());
    
    -- Create payment record
    INSERT INTO payments (order_id, amount, payment_method, status, created_at, updated_at)
    VALUES (p_order_id, total, 'card', 'pending', NOW(), NOW());
END //

-- Update order status
CREATE PROCEDURE sp_UpdateOrderStatus(
    IN p_order_id BIGINT,
    IN p_status ENUM('pending','processing','completed','cancelled')
)
BEGIN
    UPDATE orders 
    SET status = p_status, updated_at = NOW()
    WHERE id = p_order_id;
    
    -- Add notification if order is completed
    IF p_status = 'completed' THEN
        INSERT INTO notifications (user_id, message, created_at, updated_at)
        SELECT user_id, CONCAT('Your order #', p_order_id, ' has been delivered'), NOW(), NOW()
        FROM orders WHERE id = p_order_id;
    END IF;
END //

DELIMITER ;