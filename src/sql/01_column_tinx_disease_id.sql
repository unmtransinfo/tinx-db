/* Create tinx_disease.id and index. */
START TRANSACTION;

ALTER TABLE tinx_disease
ADD COLUMN id INT NOT NULL;

SELECT
    @ i := 0;

UPDATE tinx_disease
SET
    id = (
        SELECT
            @ i := @ i + 1
    );

CREATE UNIQUE INDEX tinx_disease_id ON tinx_disease (id);

COMMIT;