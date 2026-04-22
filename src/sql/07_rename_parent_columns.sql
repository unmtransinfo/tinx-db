/* Rename, retype some columns. 
 */
START TRANSACTION;

ALTER TABLE dto change dtoid id VARCHAR(255);

ALTER TABLE dto change parent_i parent VARCHAR(255);

UPDATE dto
SET
    parent = REPLACE(parent, ':', '_');

COMMIT;