--Data Cleaning in SQL Query

SELECT PropertyAddress, OwnerAddress
From Portfolioproject..NashvilleHousing

--Standardize date format

SELECT SaleDate2, CONVERT(Date, SaleDate)
From Portfolioproject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashVilleHousing
ADD SaleDate2 Date;

UPDATE NashvilleHousing
SET SaleDate2 = CONVERT(Date, SaleDate)


--populated property address data

SELECT *
From Portfolioproject..NashvilleHousing
--Where PropertyAddress is Null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolioproject..NashvilleHousing a
JOIN Portfolioproject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolioproject..NashvilleHousing a
JOIN Portfolioproject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolioproject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM Portfolioproject..NashvilleHousing

ALTER TABLE NashVilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing
ADD PropertyCityAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolioproject..NashvilleHousing

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashVilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashVilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolioproject..NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	    WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM Portfolioproject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE  WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	    WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
FROM Portfolioproject..NashvilleHousing

--REMOVE DUPLICATE

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Remove Unused Column

ALTER TABLE NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
