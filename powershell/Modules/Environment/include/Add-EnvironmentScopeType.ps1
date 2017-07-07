#region add custom Data types

  Enum EnvironmentScope {
    Process  = 0x0001
    Volatile = 0x0002
    User     = 0x0004
    Machine  = 0x0008
  }

  Enum EnvironmentData {
    Name   = 0x0010
    Value  = 0x0020
    Source = 0x0004
  }

#endregion add custom Data Types