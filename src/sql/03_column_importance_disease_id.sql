/* Create tinx_importance.disease_id and set to correct columns from tinx_disease.
 *
 * Does NOT create index. 
 */
START TRANSACTION;

ALTER TABLE tinx_importance
ADD COLUMN disease_id INT;

UPDATE tinx_importance
JOIN tinx_disease ON tinx_disease.doid = tinx_importance.doid
SET
  disease_id = tinx_disease.id;

COMMIT;