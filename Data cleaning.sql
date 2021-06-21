use data_analytics;
-- ---------------------------------------------------Change SalesDate into DateTime ---------------------------------------------------------------------------------
#change the dalesDate datatype varchar to datetime
select SalesDate ,str_to_Date(SalesDate,'%M %d,%Y')
from nashville;

#update into table
update  nashville
set SalesDate=str_to_Date(SalesDate,'%M %d,%Y');

-- ----------------------------------------------Fill the null address by same parcelid -------------------------------------------------------------------------------- 
select propertyAddress,UniqueID
from nashville
where propertyAddress= '0';

UPDATE nashville 
SET propertyAddress= NULL 
WHERE  propertyAddress  = "0";

select a.UniqueID,b.UniqueID,a.ParcelID,b.ParcelID,a.propertyAddress,b.propertyAddress,Ifnull(a.propertyAddress,b.propertyAddress)
from nashville a
join nashville b
on a.ParcelID=b.ParcelID
where a.propertyAddress is Null AND a.UniqueID<>b.UniqueID;

update nashville a
join nashville b
on a.ParcelID=b.ParcelID
set a.propertyAddress=ifnull(a.propertyAddress,b.propertyAddress)
where a.propertyAddress is Null AND a.UniqueID<>b.UniqueID;

-- --------------------------------------------------Spliting the PropertyAddresss----------------------------------------------------------------------------
select propertyAddress,
	   substring(propertyAddress,1,position("," in propertyAddress)-1) as Addess,
	   substring(propertyAddress,position("," in propertyAddress)+1) as city
from nashville;

Alter table nashville
Add Address varchar(250),
Add city varchar(250);

update nashville
set Address=substring(propertyAddress,1,position("," in propertyAddress)-1),
	city=substring(propertyAddress,position("," in propertyAddress)+1) ;

-- ------------------------------------------------Spliting the ownerAddress-----------------------------------------------------------------------------    
select OwnerAddress,substring_index(OwnerAddress,',',1) as owneraddress,
		substring_index(substring_index(OwnerAddress,',',2),',',-1) as ownercity,
        substring_index(OwnerAddress,',',-1) as ownerstate
from nashville;

alter table nashville
add Ownerplace varchar(250),
add Ownercity varchar(250),
add Ownerstate varchar(250);

update nashville
set Ownerplace=substring_index(OwnerAddress,',',1),
 Ownercity=substring_index(substring_index(OwnerAddress,',',2),',',-1),
 Ownerstate=substring_index(OwnerAddress,',',-1);
 
-- -------------------------------------------------Modifying the SoldAsVacant column-------------------------------------------------------------------------------- 
select Distinct(SoldAsVacant)
from nashville;

Update nashville
set SoldAsVacant="Yes"
where SoldAsVacant ="Y";

Update nashville
set SoldAsVacant="No"
where SoldAsVacant ="N";

-- -----------------------------------------------------------REMOVE DUPLICATE-----------------------------------------------------------------------------
#give error:error code: 1288. the target table rownum cte of the delete is not updatable
with RowNUMCTE as(
select *,row_number() over(Partition By 
					  ParcelID,
					   propertyAddress,
                       LegaReference,
                       SalesDate,
                       Salesprice order
                       by UniqueID) as row_no
from nashville)
select * 
from RowNUMCTE
where row_no>1;


delete from nashville
where uniqueid in
(select uniqueid
from
(select uniqueid ,row_number() over(Partition By 
					  ParcelID,
					   propertyAddress,
                       LegaReference,
                       SalesDate,
                       Salesprice order
                       by UniqueID) sub 
from nashville ) as a
where sub>1);
-- -----------------------------------------------------------Delete Column-----------------------------------------------------------------------------

Alter table nashville
drop  propertyAddress,
drop TaxDistrict,
drop OwnerAddress;





