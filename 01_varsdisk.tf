variable "default" { type = "map" }
variable "vms" { type = "list" }
variable "disks" { type = "list" }
variable "depends_id" { type = "string" default = ""}

#set the default disk name list as this is going to be mostly standard but still providing the user to override when needed
variable "voting_disks" { type = "list"
  default = [
    {name = "ocr_vote_1"},
    {name = "ocr_vote_2"},
    {name = "ocr_vote_3"}
  ]
}
variable "redo_disks" { type = "list"
  default = [
    {name = "redo_log_1"},
    {name = "redo_log_2"}
  ]
}
variable "db1_disks" { type = "list"
  default = [
    {name = "data_1"},
    {name = "data_2"}
  ]
}
variable "db2_disks" { type = "list"
  default = [
    {name = "data_3"},
    {name = "data_4"}
  ]
}
variable "export_disks" { type = "list"
  default = [
    {name = "exp_1"},
    {name = "exp_2"},
    {name = "exp_3"}
  ]
}

