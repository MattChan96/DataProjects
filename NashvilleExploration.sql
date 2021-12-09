SELECT *
FROM PortfolioProject1.dbo.NashvilleData 

SELECT PropertyAddress
FROM PortfolioProject1.dbo.NashvilleData 

-- Populate Property Address data

SELECT *
FROM PortfolioProject1.dbo.NashvilleData
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleData a
JOIN PortfolioProject1.dbo.NashvilleData b 
    on a.ParcelID =  b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleData a
JOIN PortfolioProject1.dbo.NashvilleData b 
    on a.ParcelID =  b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

-- Breaking address down into individual columns

SELECT
SUBSTRING(PropertyAddress, 1,
case when CHARINDEX(' ', PropertyAddress )= 0 then LEN(PropertyAddress) 
else CHARINDEX(',', PropertyAddress) -1 end) as PropertySplitAddress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertySplitCity
FROM PortfolioProject1.dbo.NashvilleData 

ALTER Table NashvilleData
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,
case when CHARINDEX(' ', PropertyAddress )= 0 then LEN(PropertyAddress) 
else CHARINDEX(',', PropertyAddress) -1 end)

ALTER TABLE NashvilleData
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

SELECT OwnerAddress
FROM PortfolioProject1.dbo.NashvilleData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject1.dbo.NashvilleData

ALTER TABLE NashvilleData
ADD OwnerSplitAddress NVARCHAR(255)
ALTER TABLE NashvilleData
ADD OwnerSplitCity NVARCHAR(255)
ALTER TABLE NashvilleData
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
UPDATE NashvilleData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
UPDATE NashvilleData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Clean SoldAsVacant Column

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject1.dbo.NashvilleData
GROUP BY SoldAsVacant
ORDER BY 2

DELETE from NashvilleData 
WHERE SoldAsVacant is NULL 
AND SoldAsVacant IN ('0  COUCHVILLE PIKE, HERMITAGE, TN', '142  SCENIC VIEW RD, OLD HICKORY, TN', '144  SCENIC VIEW RD, OLD HICKORY, TN')

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
       END 
From PortfolioProject1.dbo.NashvilleData

Update NashvilleData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
       END

-- Remove Duplicates

With RowCTE AS(
SELECT *,
    ROW_NUMBER() Over(
    PARTITION by ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER by
                    UniqueID
                    ) row_num

FROM PortfolioProject1.dbo.NashvilleData
)
Select * 
FROM RowCTE
Where row_num > 1

-- Delete useless Columns

Select *
FROM PortfolioProject1.dbo.NashvilleData

Alter Table NashvilleData
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 