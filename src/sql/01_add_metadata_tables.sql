/* add_metadata_tables.sql
 *
 * Creates metadata tables to store cached data for display in the TIN-X app.
 * The computed metadata includes the count of important targets per disease
 * and the count of important disease per target -- all derivable from the
 * database, but slow to compute.
 *
 * This script also creates the nds_rank table, which will be populated by a
 * separate python script.
 */
START TRANSACTION;

/* Important targets per disease. */
DROP TABLE IF EXISTS tinx_disease_metadata;

CREATE TABLE IF NOT EXISTS
  tinx_disease_metadata (
    id INT AUTO_INCREMENT,
    doid VARCHAR(255) NOT NULL,
    num_important_targets INT,
    PRIMARY KEY (id),
    KEY (doid)
  );

INSERT INTO
  tinx_disease_metadata (doid, num_important_targets)
SELECT
  tinx_disease.doid AS doid,
  COUNT(DISTINCT (tinx_importance.protein_id)) AS num_important_targets
FROM
  tinx_disease
  LEFT JOIN tinx_importance ON tinx_importance.doid = tinx_disease.doid
GROUP BY
  tinx_disease.doid;

/* Important diseases per protein. */
DROP TABLE IF EXISTS tinx_protein_metadata;

CREATE TABLE IF NOT EXISTS
  tinx_protein_metadata (
    id INT AUTO_INCREMENT,
    protein_id INT,
    num_important_diseases INT,
    PRIMARY KEY (id),
    FOREIGN KEY (protein_id) REFERENCES protein (id)
  );

INSERT INTO
  tinx_protein_metadata (protein_id, num_important_diseases)
SELECT
  protein.id AS protein_id,
  COUNT(DISTINCT (tinx_importance.doid)) AS num_important_diseases
FROM
  protein
  LEFT JOIN tinx_importance ON tinx_importance.protein_id = protein.id
GROUP BY
  protein.id;

/* Currently empty. This will be populated by a python script. */
CREATE TABLE IF NOT EXISTS
  tinx_nds_rank (
    id INT NOT NULL AUTO_INCREMENT,
    doid VARCHAR(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
    protein_id INT,
    `rank` INT,
    PRIMARY KEY (id),
    KEY (protein_id),
    KEY tinx_nds_rank_rank_asc (`rank`),
    FOREIGN KEY (doid) REFERENCES tinx_importance (doid)
  );

COMMIT;