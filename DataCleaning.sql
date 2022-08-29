/*

Cleaning Data in SQL

*/

--SKILLS USED: Convert, ISNULL, JOIN, ALTER TABLE, UPDATE, SUBSTIRNG, PERSENAME,  
-- WINDOW FUNCTION, CASE, CTE.

SELECT * 
FROM NashvileHousing


--Standardise SalesDate Format
SELECT Saledate, CONVERT(DATE,Saledate)
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD SaleDateConverted DATE

UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(DATE,Saledate)

---------------------------------------------------------------------------------------------------------------------------

--Populate the missing Property Address Data
SELECT * 
FROM NashvileHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, (ISNULL(a.PropertyAddress, b.PropertyAddress))
FROM NashvileHousing a
JOIN NashvileHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS  NULL;

UPDATE a
SET PropertyAddress = (ISNULL(a.PropertyAddress, b.PropertyAddress))
FROM NashvileHousing a
JOIN NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-------------------------------------------------------------------------------------------------------------------------


--Breaking Property Address into Individual Columns (Address, City,)
-- Using Substring
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD PropertySplitAdress NVARCHAR(250);

UPDATE NashvileHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvileHousing
ADD PropertySplitCity NVARCHAR(250);

UPDATE NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

---------------------------------------------------------------------------------------------------------------------------

--Breaking Owner's Address into Individual Columns (Address, City, State)
-- Using PERSENAME
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvileHousing

ALTER TABLE NashvileHousing
ADD OwnerSplitAddress NVARCHAR(250);

UPDATE NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvileHousing
ADD OwnerSplitCity NVARCHAR(250);

UPDATE NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvileHousing
ADD OwnerSplitState NVARCHAR(250);

UPDATE NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-------------------------------------------------------------------------------------------------------------------------------


--Modifying inclomplete words Using Case Statement
--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END 
FROM NashvileHousing;

UPDATE NashvileHousing
SET SoldAsVacant = CASE
       WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
 END ;

--------------------------------------------------------------------------------------------------------------------


 --Identifying and Removing Duplicate Using CTE
 WITH RowNumCTE AS (
 SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
					 PropertyAddress,
				   SalePrice,
				    SaleDate,
				    LegalReference
				   Order BY
				  UniqueID
				 ) as row_num
FROM NashvileHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

----------------------------------------------------------------------------------------------------------------

--Dropping Unused Colunm
ALTER TABLE NashvileHousing
DROP COLUMN ownerAddress, PropertyAddress, SaleDate; 

SELECT *
FROM NashvileHousing

--------------------------------------------------------------------------------------------------------------------------
