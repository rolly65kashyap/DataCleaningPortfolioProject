SELECT * 
FROM [PortfolioProject-Alex]..NashvilleHousing

--Standardizing Date Format(Removing the TimeStamp)

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [PortfolioProject-Alex]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM [PortfolioProject-Alex]..NashvilleHousing

--Populate Propert Address Data

 SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM [PortfolioProject-Alex]..NashvilleHousing A
JOIN [PortfolioProject-Alex]..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM [PortfolioProject-Alex]..NashvilleHousing A
JOIN [PortfolioProject-Alex]..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--Breaking Address Columns Into Individual Columns (Address, City, State)
--Formating OwnerAddress
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress)) AS City
FROM [PortfolioProject-Alex]..NashvilleHousing A

--Creating 2 new columns to add the Split Values
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,LEN(PropertyAddress))

SELECT *
FROM [PortfolioProject-Alex]..NashvilleHousing

--Formating OwnerAddress
SELECT OwnerAddress
FROM [PortfolioProject-Alex]..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [PortfolioProject-Alex]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM [PortfolioProject-Alex]..NashvilleHousing

--Change Y and N to Yes and No in SoldAsVacant field

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM [PortfolioProject-Alex]..NashvilleHousing

UPDATE [PortfolioProject-Alex]..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueId
					) AS row_num
FROM [PortfolioProject-Alex]..NashvilleHousing
)
--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1	--Gives all the duplicate rows
--ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num > 1

--Delete Unused Columns

SELECT *
FROM [PortfolioProject-Alex]..NashvilleHousing

ALTER TABLE [PortfolioProject-Alex]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE [PortfolioProject-Alex]..NashvilleHousing
DROP COLUMN SaleDate