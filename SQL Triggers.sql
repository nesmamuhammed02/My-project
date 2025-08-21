CREATE TABLE product_audits(
    change_id INT IDENTITY PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    model_year SMALLINT NOT NULL,
    list_price DEC(10,2) NOT NULL,
    updated_at DATETIME NOT NULL,
    operation CHAR(3) NOT NULL,
    CHECK(operation = 'INS' or operation='DEL')
);
create or alter trigger keep_changes
on products
after insert,delete
as
begin
INSERT INTO
 product_audits
        (
            product_id,
            product_name,
            brand_id,
            category_id,
            model_year,
            list_price,
            updated_at,
            operation
        )
SELECT
    i.product_id,
    product_name,
    brand_id,
    category_id,
    model_year,
    i.list_price,
    GETDATE(),
    'INS'
FROM
    inserted AS i
UNION ALL
    SELECT
        d.product_id,
        product_name,
        brand_id,
        category_id,
        model_year,
        d.list_price,
        getdate(),
        'DEL'
    FROM
        deleted AS d;

end
-----------------------------------
create or alter trigger update_avilable_tickets
on reservation
after insert
as
begin
set nocount on
update trips
set seats_available= seats_available - i.no_of_ticket
from trips t,inserted i
where t.trip_id=i.trip_id
end

create or alter trigger check_seats
on reservation
as 
begin
set nocount on
if exists(
select * from trips t , inserted i
where t.trip_id=i.trip_id and t.seats_available>=i.no_of_tickets
)
insert into reservation
select * from inserted
else
raiserror('sorry,no available seats',16,1)
end