SELECT * 
FROM DataCleaningPortfolioProject.dbo.Nashville;

/*

Cleaning Data in the Queries

*/
------------------------------------------------------

--Standardize Data Format

SELECT SaleDate,CONVERT(date,SaleDate)
FROM DataCleaningPortfolioProject.dbo.Nashville;


ALTER TABLE Nashville
ADD SaleDateConverted date;

UPDATE Nashville
SET SaleDateConverted = CONVERT(date,SaleDate);

SELECT SaleDateConverted
FROM DataCleaningPortfolioProject.dbo.Nashville;




---------------------------------------------------------

--Populate Property Address Data

SELECT * 
FROM DataCleaningPortfolioProject.dbo.Nashville
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID

SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM DataCleaningPortfolioProject.dbo.Nashville A
JOIN DataCleaningPortfolioProject.dbo.Nashville B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


UPDATE A
SET PropertyAddress =  ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM DataCleaningPortfolioProject.dbo.Nashville A
JOIN DataCleaningPortfolioProject.dbo.Nashville B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

----------------------------------------

--Breaking Out Address into Individual Columns (Address,City,State)

SELECT PropertyAddress
FROM DataCleaningPortfolioProject.dbo.Nashville
--WHERE PropertyAddress IS NULL;
--ORDER BY ParcelID


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM DataCleaningPortfolioProject.dbo.Nashville


ALTER TABLE DataCleaningPortfolioProject.dbo.Nashville
ADD PropertySplitAddress nvarchar(255);


UPDATE DataCleaningPortfolioProject.dbo.Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);


ALTER TABLE DataCleaningPortfolioProject.dbo.Nashville
ADD PropertySplitCity nvarchar(255);


UPDATE DataCleaningPortfolioProject.dbo.Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity
FROM DataCleaningPortfolioProject.dbo.Nashville;




SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM DataCleaningPortfolioProject.dbo.Nashville;

ALTER TABLE DataCleaningPortfolioProject.dbo.Nashville
ADD OwnerSplitAddress nvarchar(255);


UPDATE DataCleaningPortfolioProject.dbo.Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE DataCleaningPortfolioProject.dbo.Nashville
ADD OwnerSplitCity nvarchar(255);


UPDATE DataCleaningPortfolioProject.dbo.Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE DataCleaningPortfolioProject.dbo.Nashville
ADD OwnerSplitState nvarchar(255);


UPDATE DataCleaningPortfolioProject.dbo.Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT *
FROM DataCleaningPortfolioProject.dbo.Nashville;

------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant) , COUNT(SoldAsVacant)
FROM DataCleaningPortfolioProject.dbo.Nashville
GROUP BY SoldAsVacant;

UPDATE DataCleaningPortfolioProject.dbo.Nashville
SET SoldAsVacant = 'Y'
WHERE SoldAsVacant = 'Yes';

UPDATE DataCleaningPortfolioProject.dbo.Nashville
SET SoldAsVacant = 'N'
WHERE SoldAsVacant = 'No';



--Case Statement

SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM DataCleaningPortfolioProject.dbo.Nashville;

UPDATE DataCleaningPortfolioProject.dbo.Nashville
SET SoldAsVacant =   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant ='N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-----------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(Partition By parcelID,
				PropertyAddress,
				SalePrice,SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM DataCleaningPortfolioProject.dbo.Nashville
)
SELECT *
FROM RowNumCTE
WHERE row_num>1
--ORDER BY PropertyAddress;

----------------------------------------

--Delete Unused Columns

SELECT *
FROM DataCleaningPortfolioProject.dbo.Nashville

ALTER TABLE DataCleaningPortfolioProject.dbo.Nashville
DROP COLUMN SaleDate;