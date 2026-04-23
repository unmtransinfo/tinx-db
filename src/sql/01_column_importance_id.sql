/* Create tinx_importance.id and index. */
START TRANSACTION;

SELECT
    @ i := 0;

ALTER TABLE tinx_importance
ADD COLUMN id INT NOT NULL;

UPDATE tinx_importance
SET
    id = (
        SELECT
            @ i := @ i + 1
    );

CREATE UNIQUE INDEX tinx_importance_id ON tinx_importance (id);

COMMIT;