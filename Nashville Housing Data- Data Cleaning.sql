/*

Cleaning Data in SQL

*/

Select *
From Portfolio_Project.dbo.NashvilleHousing
----------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Portfolio_Project.dbo.NashvilleHousing

Update Portfolio_Project.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
--OR

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update Portfolio_Project.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
-------------

SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio_Project.dbo.NashvilleHousing
-------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing A
JOIN Portfolio_Project.dbo.NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A. PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing A
JOIN Portfolio_Project.dbo.NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A. PropertyAddress IS NULL
-------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD PropertySplitAddress VARCHAR(250);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD PropertySplitCity VARCHAR(250);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT * FROM Portfolio_Project.dbo.NashvilleHousing


SELECT OwnerAddress
FROM Portfolio_Project.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD OwnerSplitAddress VARCHAR(250);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD OwnerSplitCity VARCHAR(250);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD OwnerSplitState VARCHAR(250);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM Portfolio_Project.dbo.NashvilleHousing
-----------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio_Project.dbo.NashvilleHousing

Update Portfolio_Project.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
-------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY UniqueID)row_num
From Portfolio_Project.dbo.NashvilleHousing
)
DELETE FROM RowNumCTE
Where row_num > 1
--Order by PropertyAddress


WITH RowNumCTE AS(
SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY UniqueID)row_num
From Portfolio_Project.dbo.NashvilleHousing
)
SELECT * FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress


SELECT *
From Portfolio_Project.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
From Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN 
OwnerAddress, TaxDistrict, PropertyAddress,SaleDate