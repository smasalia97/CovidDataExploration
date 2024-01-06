SELECT * FROM PortfolioProject..Housing


-- Giving correct format to date
SELECT SaleDate, CONVERT(Date, Saledate) 
FROM PortfolioProject..Housing

-- Doesnt work w/o ALTER
Update Housing 
SET Saledate = CONVERT(Date, Saledate) 

-- 
ALTER TABLE Housing
Add SaleDateConverted Date;

Update Housing 
SET Saledate = CONVERT(Date, Saledate) 


-- Fill empty val in Property Address Data
SELECT *
FROM PortfolioProject..Housing
--Where PropertyAddress is null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Housing a
JOIN PortfolioProject..Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.Housing a
JOIN PortfolioProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out address into individual columnns

Select *
From PortfolioProject..Housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.Housing

ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255);
Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);
Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select OwnerAddress
From PortfolioProject..Housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.Housing

ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255);
Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);
Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);
Update Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject..Housing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) as Count
From PortfolioProject..Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
END
FROM PortfolioProject..Housing

UPDATE Housing
SET SoldAsVacant = 
CASE
	 When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
END

-- Duplicates Removal
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

From PortfolioProject..Housing)

DELETE 
From RowNumCTE
WHERE row_num > 1

-- Delete unused columns
ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfolioProject.dbo.Housing
