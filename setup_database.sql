USE HousingDataCleaning;

DROP TABLE NashvilleHousing;
CREATE TABLE NashvilleHousing (
	UniqueID INT,
    ParcelID VARCHAR(100),
    LandUse VARCHAR(100), 
    PropertyAddress VARCHAR(100),
    SaleDate VARCHAR(100),
    SalePrice INT,
    LegalReference VARCHAR(100),
    SoldAsVacant VARCHAR(100),
    OwnerName VARCHAR(100),
    OwnerAddress VARCHAR(100),
    Acreage FLOAT,
    TaxDistrict VARCHAR(100),
    LandValue INT,
    BuildingValue INT,
    TotalValue INT,
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

-- Data Import for NashvilleHousing
LOAD DATA LOCAL INFILE '/path/to/your/Nashville Housing Data for Data Cleaning.csv'
INTO TABLE NashvilleHousing
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
	UniqueID,
    ParcelID,
    LandUse, 
    PropertyAddress,
    SaleDate,
    SalePrice,
    LegalReference,
    SoldAsVacant,
    OwnerName,
    OwnerAddress,
    Acreage,
    TaxDistrict,
    LandValue,
    BuildingValue,
    TotalValue,
    YearBuilt,
    Bedrooms,
    FullBath,
    HalfBath
)
SET
	UniqueID = NULLIF(UniqueID, ''),
    ParcelID = NULLIF(ParcelID, ''),
    LandUse = NULLIF(LandUse, ''), 
    PropertyAddress = NULLIF(PropertyAddress, ''),
    SaleDate = NULLIF(SaleDate, ''),
    SalePrice = NULLIF(SalePrice, ''),
    LegalReference = NULLIF(LegalReference, ''),
    SoldAsVacant = NULLIF(SoldAsVacant, ''),
    OwnerName = NULLIF(OwnerName, ''),
    OwnerAddress = NULLIF(OwnerAddress, ''),
    Acreage = NULLIF(Acreage, ''),
    TaxDistrict = NULLIF(TaxDistrict, ''),
    LandValue = NULLIF(LandValue, ''),
    BuildingValue = NULLIF(BuildingValue, ''),
    TotalValue = NULLIF(TotalValue, ''),
    YearBuilt = NULLIF(YearBuilt, ''),
    Bedrooms = NULLIF(Bedrooms, ''),
    FullBath = NULLIF(FullBath, ''),
    HalfBath = NULLIF(HalfBath, '')
;