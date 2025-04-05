DELIMITER //

-- Create new restaurant
CREATE PROCEDURE sp_CreateRestaurant(
    IN p_owner_id BIGINT,
    IN p_name VARCHAR(100),
    IN p_description TEXT,
    IN p_logo_url VARCHAR(255),
    IN p_opening_time TIME,
    IN p_closing_time TIME,
    OUT p_restaurant_id BIGINT
)
BEGIN
    INSERT INTO restaurants (owner_id, name, description, logo_url, opening_time, closing_time, created_at, updated_at)
    VALUES (p_owner_id, p_name, p_description, p_logo_url, p_opening_time, p_closing_time, NOW(), NOW());
    
    SET p_restaurant_id = LAST_INSERT_ID();
END //

-- Get restaurant details with menu
CREATE PROCEDURE sp_GetRestaurantWithMenu(
    IN p_restaurant_id BIGINT
)
BEGIN
    -- Restaurant info
    SELECT * FROM restaurants WHERE id = p_restaurant_id;
    
    -- Categories with food items
    SELECT c.id AS category_id, c.name AS category_name, 
           f.id AS food_id, f.name AS food_name, f.description, f.price, f.image, f.is_available
    FROM categories c
    LEFT JOIN food_items f ON c.id = f.category_id
    WHERE c.restaurant_id = p_restaurant_id
    ORDER BY c.id, f.id;
END //

DELIMITER ;