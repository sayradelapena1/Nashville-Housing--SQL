/* 
Cleaning data in sql queries
*/ 

Select * 
From PortfolioP.dbo.NashvilleHousing




/* Standardize Date Format (remove the time function from date) */

Select SaleDate
From PortfolioP.dbo.NashvilleHousing

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioP.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
--created a table for the new date without the time (SaleDateConverted-- 



/* Populate Property Address Data */

Select *
From PortfolioP.dbo.NashvilleHousing
Where PropertyAddress is null       --looking at all null information -- 

Select *
From PortfolioP.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID                   --ParceID will have the connection to missing address--

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)       -- ISNULL = checking what is null, and what to pupulate in it if it is null --
From PortfolioP.dbo.NashvilleHousing a
JOIN PortfolioP.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID			-- parcelID will be the same -- 
	AND a.[UniqueID ] <> b.[UniqueID ]     --uniqueID will be differnt from each other == 
Where a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioP.dbo.NashvilleHousing a
JOIN PortfolioP.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID	
	AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null           -- updates the table to remove null values -- 




/* Dividing address into individual columns (street,city) */

Select PropertyAddress
From PortfolioP.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address     --looking at Property Address, 1st value, before the comma, -1 deletes the comma  -- 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address     --looking at Property Addess, comma values, one over the comma, length of the address --
From PortfolioP.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
--created a new table for the proeprty split address (street, PropertySplitAddress) --


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))
----created a new table for the proeprty split address (city, PropertySplitCity) --


Select * 
From PortfolioP.dbo.NashvilleHousing






/* Split the owner address from street,city,state) */

Select OwnerAddress
From PortfolioP.dbo.NashvilleHousing

Select
PARSENAME(OwnerAddress, 1)			--PARSENAME is only useful with periods, so you need to replace the commas with periods.--
From PortfolioP.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)	--needs to be in reverse order 3,2,1--
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)	
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)	 
From PortfolioP.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select * 
From PortfolioP.dbo.NashvilleHousing





/* Change Y and N to Yes and No in "sold as Vacant" */

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)			-- the distinct answers in sold as vacant -- 
From PortfolioP.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant
, CASE When SoldASVacant = 'Y' Then 'Yes'
	When SoldASVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
From PortfolioP.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldASVacant = 'Y' Then 'Yes'
						When SoldASVacant = 'N' Then 'No'
						ELSE SoldAsVacant
						END
--updated the table to only 'yes' and 'no' --






/* Remove duplicates */

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice,
				SaleDate, 
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

From PortfolioP.dbo.NashvilleHousing
--ORDER BY ParcelID
) 
DELETE						-- will delete all duplicates -- 
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



WITH RowNumCTE AS(
Select *,					-- same functions as above, un this after the above one to check for duplicates -- 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SalePrice,
				SaleDate, 
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

From PortfolioP.dbo.NashvilleHousing
--ORDER BY ParcelID
) 
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress







/* Delete unused columns */

Select * 
From PortfolioP.dbo.NashvilleHousing


ALTER TABLE PortfolioP.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 
--deleted these columns--

ALTER TABLE PortfolioP.dbo.NashvilleHousing
DROP COLUMN SaleDate
--deleted these columns--