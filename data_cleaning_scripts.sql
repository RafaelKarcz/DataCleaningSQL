/*
Data Cleaning Operations for NashvilleHousing Dataset
This script outlines a series of data cleaning operations performed on the NashvilleHousing dataset,
aiming to standardize formats, fill missing information, and ensure data integrity.
*/

-- Establish context by selecting the appropriate database
USE HousingDataCleaning;

-- Display the initial state of the data for reference before making changes
SELECT * FROM NashvilleHousing;

-- Standardize the date format across all records to enhance consistency and facilitate date-based queries
SET SQL_SAFE_UPDATES = 0;
UPDATE NashvilleHousing
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d')
WHERE STR_TO_DATE(SaleDate, '%M %d, %Y') IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

-- Populate missing addresses in PropertyAddress using similar entries from the same dataset to improve data completeness
SET SQL_SAFE_UPDATES = 0;
UPDATE NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;
SET SQL_SAFE_UPDATES = 1;

-- Verify that the addresses have been correctly populated and assess the effectiveness of the address fill-in
SELECT 
    a.ParcelID AS a_ParcelID,
    a.PropertyAddress AS a_PropertyAddress, 
    b.ParcelID AS b_ParcelID,
    b.PropertyAddress AS b_PropertyAddress, 
    COALESCE(a.PropertyAddress, b.PropertyAddress) AS FallbackPropertyAddress
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Split the PropertyAddress into two columns for Address and City to enhance data granularity and usability
SELECT
    SUBSTRING(PropertyAddress, 1, IF(LOCATE(',', PropertyAddress) > 0, LOCATE(',', PropertyAddress) - 1, LENGTH(PropertyAddress))) AS Address,
    IF(LOCATE(',', PropertyAddress) > 0, TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1)), NULL) AS City
FROM NashvilleHousing;

-- Add new columns to store the split address data
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255),
ADD PropertySplitCity VARCHAR(255);
SET SQL_SAFE_UPDATES = 1;

-- Update the table with the split address data
SET SQL_SAFE_UPDATES = 0;
UPDATE NashvilleHousing
SET
    PropertySplitAddress = SUBSTRING(
        PropertyAddress, 
        1, 
        IF(LOCATE(',', PropertyAddress) > 0, LOCATE(',', PropertyAddress) - 1, LENGTH(PropertyAddress))
    ),
    PropertySplitCity = NULLIF(
        TRIM(
            SUBSTRING(
                PropertyAddress, 
                IF(LOCATE(',', PropertyAddress) > 0, LOCATE(',', PropertyAddress) + 1, LENGTH(PropertyAddress))
            )
        ),
        ''
    );
SET SQL_SAFE_UPDATES = 1;

-- Verify the results of the address splitting operation
SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing;

-- Similarly, split the OwnerAddress into Address, City, and State components to standardize and structure the data
SELECT
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
    NULLIF(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)), '') AS City,
    NULLIF(TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)), '') AS State
FROM NashvilleHousing;

-- Add new columns for the split owner address data
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255),
ADD OwnerSplitCity VARCHAR(255),
ADD OwnerSplitState VARCHAR(255);
SET SQL_SAFE_UPDATES = 1;

-- Populate the new owner address columns
SET SQL_SAFE_UPDATES = 0;
UPDATE NashvilleHousing
SET
    OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity = NULLIF(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)), ''),
    OwnerSplitState = NULLIF(TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)), '');
SET SQL_SAFE_UPDATES = 1;

-- Review the owner address splitting results
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing;

-- Translate 'Y' and 'N' in the "Sold as Vacant" field to 'Yes' and 'No' to improve data readability and clarity
SELECT SoldAsVacant, COUNT(SoldAsVacant) AS Count
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count;

-- Display the translation result of the SoldAsVacant field
SELECT 
	SoldAsVacant,
    CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE
		SoldAsVacant
	END AS TranslatedSoldAsVacant
FROM NashvilleHousing;

-- Update the "Sold as Vacant" field to reflect the new values and ensure data consistency
SET SQL_SAFE_UPDATES = 0;
START TRANSACTION;
UPDATE NashvilleHousing
SET 
    SoldAsVacant =
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-- If the update is satisfactory, commit the changes, otherwise, rollback to revert
COMMIT;
ROLLBACK;
SET SQL_SAFE_UPDATES = 1;

-- Confirm the update of the SoldAsVacant field
SELECT SoldAsVacant
FROM NashvilleHousing;

-- Identify and remove duplicate entries to maintain a clean and reliable dataset
SET SQL_SAFE_UPDATES = 0;
WITH RowNumCTE AS (
    SELECT 
        UniqueID,
        ROW_NUMBER() OVER(
            PARTITION BY 
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY
                UniqueID
        ) AS row_num
    FROM NashvilleHousing
)
-- Delete the identified duplicates while keeping the first record of each duplicate set
DELETE FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID FROM RowNumCTE WHERE row_num > 1
);
SET SQL_SAFE_UPDATES = 1;

-- Final clean-up operation by removing unused columns, typically advised against unless absolutely necessary
SELECT *
FROM NashvilleHousing;

SET SQL_SAFE_UPDATES = 0;
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress;
SET SQL_SAFE_UPDATES = 1;