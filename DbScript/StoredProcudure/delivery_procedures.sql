DELIMITER //

-- Update delivery status
CREATE PROCEDURE sp_UpdateDeliveryStatus(
    IN p_order_id BIGINT,
    IN p_status ENUM('pending','dispatched','out_for_delivery','delivered')
)
BEGIN
    INSERT INTO delivery_statuses (order_id, status, created_at, updated_at)
    VALUES (p_order_id, p_status, NOW(), NOW());
    
    -- Update order status if delivered
    IF p_status = 'delivered' THEN
        CALL sp_UpdateOrderStatus(p_order_id, 'completed');
    END IF;
END //

-- Update delivery location
CREATE PROCEDURE sp_UpdateDeliveryLocation(
    IN p_order_id BIGINT,
    IN p_latitude DECIMAL(10,8),
    IN p_longitude DECIMAL(11,8)
)
BEGIN
    DECLARE tracking_exists INT;
    
    SELECT COUNT(*) INTO tracking_exists
    FROM delivery_tracking
    WHERE order_id = p_order_id;
    
    IF tracking_exists > 0 THEN
        UPDATE delivery_tracking
        SET latitude = p_latitude, longitude = p_longitude, last_updated_at = NOW(), updated_at = NOW()
        WHERE order_id = p_order_id;
    ELSE
        INSERT INTO delivery_tracking (order_id, latitude, longitude, last_updated_at, created_at, updated_at)
        VALUES (p_order_id, p_latitude, p_longitude, NOW(), NOW(), NOW());
    END IF;
END //

DELIMITER ;