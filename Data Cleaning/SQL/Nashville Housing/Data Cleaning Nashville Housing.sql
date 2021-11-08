/*

Queries used for Nashville Data Cleaning Project

Steps going through:
    1. Standardize data format
    2. Populate Property Address data
    3. Breaking out Address into Individual Columns (Address, City, State)
    4. Change Y and N to Yes and No in "Sold as Vacant" field
    5. Remove Duplicates
    6. Delete Unused Columns

*/
------------------------------------------------------------------------------------------------------------------------
-- 1. Test Connection with the server


Select *
From NashHousingProject.dbo.NashvilleHousing LIMIT 10

------------------------------------------------------------------------------------------------------------------------
-- 2. Standardize data format


Select saleDateConverted, CONVERT(Date,SaleDate)
From NashHousingProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


------------------------------------------------------------------------------------------------------------------------
-- 3. Populate Property Address data

Select *
From NashHousingProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

/*
 We have NULL argument on PropertyAddress, we can use the parcelID for populate the missing address as follow:

Function ISNULL(expression, alt_value)
    * expression	Required. The expression to test whether is NULL
    * alt_value	    Required. The value to return if expression is NULL

 */

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashHousingProject.dbo.NashvilleHousing a
JOIN NashHousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashHousingProject.dbo.NashvilleHousing a
JOIN NashHousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




------------------------------------------------------------------------------------------------------------------------

-- 4. Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NashHousingProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From NashHousingProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From NashHousingProject.dbo.NashvilleHousing





Select OwnerAddress
From NashHousingProject.dbo.NashvilleHousing


/*
 We want to split the address on a different way as follow:

Function PARSENAME('object_name' , object_piece ) looking for periods (.) We change commas to periods with REPLACE
    * 'object_name'	    Required. The parameter that holds the name of the object for which to retrieve the specified object part
    * object_piece	    Required. The value to return if expression is NULL
Remember that PARSENAME return strings on Backwards (Right to left)

 */




Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashHousingProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NashHousingProject.dbo.NashvilleHousing




------------------------------------------------------------------------------------------------------------------------
-- 5. Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashHousingProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

/*
The output is as follow:
Y   52
N   399
Yes 4623
No  51403

For compute time we will change the values Y and N to Yes and No.
*/

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashHousingProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashHousingProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


------------------------------------------------------------------------------------------------------------------------
-- 6. Remove Duplicates

-- Find all the duplicates

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

From NashHousingProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Remove all duplicates


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

From NashHousingProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashHousingProject.dbo.NashvilleHousing




------------------------------------------------------------------------------------------------------------------------
-- 7. Delete Unused Columns



Select *
From NashHousingProject.dbo.NashvilleHousing


ALTER TABLE NashHousingProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE NashHousingProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE NashHousingProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\.....\Nashville Housing Data for Data Cleaning Project.csv' --Replace with your path
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE NashHousingProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\....\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]); --Replace with your path
--GO


















