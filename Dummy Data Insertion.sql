-- Generate dummy data to test the Fivetran interface
INSERT INTO drug_discovery (
    compound_id,
    protein_id,
    molecular_weight,
    logp,
    h_bond_donors,
    h_bond_acceptors,
    rotatable_bonds,
    polar_surface_area,
    compound_clogp,
    protein_length,
    protein_pi,
    hydrophobicity,
    binding_site_size,
    mw_ratio,
    logp_pi_interaction,
    binding_affinity,
    active
)
VALUES (
    'CID_TEST: ' || SUBSTR(CURRENT_TIMESTAMP, 1, 15), -- Add current timestamp for ease of testing
    'PID_TEST: ' || SUBSTR(CURRENT_TIMESTAMP, 1, 15), -- Add current timestamp for ease of testing
    284.243,
    1.312,
    2,
    8,
    5,
    153.088,
    0.855,
    141,
    3.847,
    0.98,
    8.865,
    0.312,
    21.181,
    9.496,
    1
);

-- Validate dummy data insertion
SELECT *
FROM drug_discovery
WHERE compound_id LIKE 'CID_TEST%';
