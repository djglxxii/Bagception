-- Scaffold load probe. Replace with the real module requires once Phase 1 starts.
-- Verifies that Script Extender loads this mod's server context at all; it does
-- nothing else and owns no gameplay behaviour.
Ext.Events.SessionLoaded:Subscribe(function()
    Ext.Utils.Print("[Bagception] Server context loaded (scaffold).")
end)
