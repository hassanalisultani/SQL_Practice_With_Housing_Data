/*
Cleaning Data in SQL Queries
*/


Select *
From Practice.dbo.HousingData


-- Standardize Date Format

ALTER Table Practice.dbo.HousingData
ADD SalesDateConverted date

Update Practice.dbo.HousingData
SET SalesDateConverted = CONVERT(Date, SaleDate)

Select SaleDate, SalesDateConverted
From Practice.dbo.HousingData


-- Populate Property Address data

Select *
From Practice.dbo.HousingData
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Practice.dbo.HousingData a
join Practice.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Practice.dbo.HousingData a
join Practice.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select *
From Practice.dbo.HousingData
Where PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select	PropertyAddress,
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
From Practice.dbo.HousingData


ALTER Table Practice.dbo.HousingData
ADD PropertySplitAddress nvarchar(255)

ALTER Table Practice.dbo.HousingData
ADD PropertySplitCity nvarchar(255)

Update Practice.dbo.HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Update Practice.dbo.HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


Select *
From  Practice.dbo.HousingData

Select *
From  Practice.dbo.HousingData



Select OwnerAddress
From  Practice.dbo.HousingData

Select	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From  Practice.dbo.HousingData

ALTER Table Practice.dbo.HousingData
ADD OwnerSplitAddress nvarchar(255)

ALTER Table Practice.dbo.HousingData
ADD OwnerSplitCity nvarchar(255)

ALTER Table Practice.dbo.HousingData
ADD OwnerSplitState nvarchar(255)

Update Practice.dbo.HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Update Practice.dbo.HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Update Practice.dbo.HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


Select *
From  Practice.dbo.HousingData



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From  Practice.dbo.HousingData
Group by SoldAsVacant
Order by 2


Select SoldAsVacant, CASE
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From  Practice.dbo.HousingData

Update Practice.dbo.HousingData
SET	SoldAsVacant = CASE
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From  Practice.dbo.HousingData



-- Remove Duplicates

With RowNumCTE as
(
Select *, ROW_NUMBER() Over (Partition by ParcelID,
							PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference
							Order by 
							UniqueID) row_num
From Practice.dbo.HousingData
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns

Select *
From Practice.dbo.HousingData

ALTER Table Practice.dbo.HousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate