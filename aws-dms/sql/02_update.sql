ALTER TABLE datagen_custom_users
ADD COLUMN first_name VARCHAR(50),
ADD COLUMN last_name VARCHAR(50);

UPDATE datagen_custom_users
SET 
    first_name = SUBSTRING_INDEX(full_name, ' ', 1),
    last_name = SUBSTRING_INDEX(full_name, ' ', -1);
