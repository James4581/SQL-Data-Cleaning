SELECT * 
FROM SQLProject1..NashvilleHousing

-- Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM SQLProject1..NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM SQLProject1..NashvilleHousing


-- Populate property address data when null

SELECT *
FROM SQLProject1..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --replace if a is null
FROM SQLProject1..NashvilleHousing a
JOIN SQLProject1..NashvilleHousing b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] --not equal
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLProject1..NashvilleHousing a
JOIN SQLProject1..NashvilleHousing b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] --not equal
WHERE a.PropertyAddress is null


-- Breaking out address into multiple columns (address, city, state)


SELECT PropertyAddress
FROM SQLProject1..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address--charindex similar to find funciton
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS City
FROM SQLProject1..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD Address1 NVARCHAR(450);

UPDATE NashvilleHousing
SET Address1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD City NVARCHAR(450);

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

SELECT *
FROM SQLProject1..NashvilleHousing


-- Splitting owner address (includes state)

SELECT OwnerAddress
FROM SQLProject1..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) -- Parsename breaks out by period (works backwards)
FROM SQLProject1..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddress1 NVARCHAR(450);

UPDATE NashvilleHousing
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(450);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(450);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM SQLProject1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' --if elif statement
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM SQLProject1..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' --if elif statement
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



-- Remove duplicates


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY 
			UniqueID) row_num
FROM SQLProject1..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY 
			UniqueID) row_num
FROM SQLProject1..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-- Delete unused columns 



SELECT *
FROM SQLProject1..NashvilleHousing


ALTER TABLE SQLProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE SQLProject1..NashvilleHousing
DROP COLUMN SaleDate