SELECT *
FROM HousingData.dbo.NashvilleHousing;

-- Standardize Date format
SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM HousingData.dbo.NashvilleHousing;

UPDATE HousingData.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);


ALTER TABLE HousingData.dbo.NashvilleHousing
ADD SaleDateConverted DATE;
UPDATE HousingData.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

--------------------------------------------------------------------------------
-- Populate property address data
-- We can clearly see that where the parcel ID is repeated, the property address in null
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData.dbo.NashvilleHousing a
JOIN HousingData.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


------------------------------------------------------------------------------------------------------------

-- Breaking Out the address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM HousingData.dbo.NashvilleHousing;


SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
FROM HousingData.dbo.NashvilleHousing;

ALTER TABLE HousingData.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
UPDATE HousingData.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);


ALTER TABLE HousingData.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
UPDATE HousingData.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Doing Same things with OwnerAddress
SELECT OwnerAddress
FROM HousingData.dbo.NashvilleHousing;

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), -- It works backwards
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM HousingData.dbo.NashvilleHousing;

ALTER TABLE HousingData.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE HousingData.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


ALTER TABLE HousingData.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE HousingData.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


ALTER TABLE HousingData.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
UPDATE HousingData.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


----------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SolidAsVacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingData.dbo.NashvilleHousing -- Contains Y, Yes, No, N
GROUP BY SoldAsVacant
order by 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM HousingData.dbo.NashvilleHousing;


UPDATE HousingData.dbo.NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					END;

------------------------------------------------------------------------------
-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
			) row_num
FROM HousingData.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress;
-- All these we got are duplicates, should be deleted


WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
			) row_num
FROM HousingData.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num>1;


-----------------------------------------------------------------------
-- Delete Unused Columns
ALTER TABLE HousingData.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;


SELECT *
FROM HousingData.dbo.NashvilleHousing;