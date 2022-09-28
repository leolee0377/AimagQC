
function   app = reload_UI (app)

  try load([app.Source_Path filesep 'QCV2pathSettings.mat'],'T_*') ;
     % SAVE UI CONFIG WHEN QC PRESSED: 
     try app.CheckBox.Value =  T_Cbox_HE ;   catch            end %#ok<*SEPEX>
     try app.CheckBox_3.Value  = T_Cbox_TCT ;   catch            end
     try app.FocusEditField.Value = T_HE_Focus;   catch            end
     try app.FocusEditField_2.Value = T_MF_Focus;   catch            end
     try app.FocusEditField_3.Value  = T_TC_Focus;   catch            end
     try app.ArtefactsEditField.Value = T_HE_Artefacts;   catch            end
     try app.ArtefactsEditField_2.Value = T_MF_Artefacts;   catch            end
     try app.ArtefactsEditField_3.Value  = T_TC_Artefacts;   catch            end
     try app.SaturationEditField.Value = T_HE_Saturation ;   catch            end
     try app.SaturationEditField_2.Value  = T_MF_Saturation ;   catch            end
     try app.SaturationEditField_3.ValueT_TC_Saturation ;   catch            end
     
     try app.ContrastEditField.Value  =T_HE_Contrast;   catch            end
     try app.ContrastEditField_2.Value  = T_MF_Contrast ;   catch            end
     try app.ContrastEditField_3.Value = T_TC_Contrast ;   catch            end
     
     try app.UniformityEditField.Value = T_HE_Uniformity ;   catch            end
     try app.UniformityEditField_2.Value  = T_MF_Uniformity ;   catch            end
     try app.UniformityEditField_3.Value  = T_TC_Uniformity ;   catch            end
     
     try app.OverallEditField.Value  = T_HE_Overall;   catch            end
     try app.OverallEditField_2.Value  = T_MF_Overall;   catch            end
     try app.OverallEditField_3.Value  = T_TC_Overall ;   catch            end
     
     try app.p1.Position = T_AX_p1 ;   catch            end
     try app.p2.Position = T_AX_p2 ;   catch            end
     try app.Language  = T_Lang ;   catch            end
  catch
     disp('Default User Interface.') 
  end