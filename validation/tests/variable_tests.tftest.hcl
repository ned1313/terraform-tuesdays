run "vm_size_e_series" {
    command = plan

    variables {
        vm_size = "Standard_E12s_v5"
    }
}

run "test_g_series" {
    command = plan

    variables {
        vm_size = "Standard_G4s_v5"
    }

    expect_failures = [
        var.vm_size
    ]

}