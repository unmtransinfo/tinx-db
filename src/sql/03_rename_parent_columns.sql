/* Normalize dto.parent_id to the canonical CURIE format (e.g. PR:000000001)
 * expected by the UI/API. */
START TRANSACTION;

UPDATE dto
SET
    parent_id =
REPLACE
    (parent_id, '_', ':');

COMMIT;