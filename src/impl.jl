
struct Handler3D
    c_ptr::Ptr{Cvoid}
end

struct OpenGlRenderState
    c_ptr::Ptr{Cvoid}
end

struct View
    c_ptr::Ptr{Cvoid}
end


# void pangolin_create_window(char* window_name, int width, int height, int panel) {
function create_window(name::String, width::Int, height::Int; panel::Int=0)::Nothing
    ccall((:pangolin_create_window, :libpangolin_c_api),
          Cvoid,
          (Cstring, Cint, Cint, Cint),
          name, Cint(width), Cint(height), Cint(panel))
    return
end

function OpenGlRenderState(
        projection_mat::Matrix{Float64},
        model_view_mat::Matrix{Float64})
    # void* pangolin_create_render_state(
    #         float* proj_mat_ptr,
    #         float* model_view_ptr
    #         )
    proj_ptr = Base.unsafe_convert(Ptr{Cdouble}, projection_mat)
    model_view_ptr = Base.unsafe_convert(Ptr{Cdouble}, model_view_mat)
    s_cam = ccall((:pangolin_create_render_state, :libpangolin_c_api),
                  Ptr{Cvoid},
                  (Ptr{Cdouble}, Ptr{Cdouble}),
                  proj_ptr, model_view_ptr)
    OpenGlRenderState(s_cam)
end

# void* pangolin_create_render_state_no_params()
function OpenGlRenderState()
    s_cam = ccall((:pangolin_create_render_state_no_params, :libpangolin_c_api),
                  Ptr{Cvoid},
                  ())
    OpenGlRenderState(s_cam)
end


function get_projection_view_mat(s_cam::OpenGlRenderState)
    out = Matrix{Cdouble}(undef, 4, 4)
    out_ptr = Base.unsafe_convert(Ptr{Cdouble}, out)
    # pangolin_get_projection_model_view_matrix

        ccall((:pangolin_get_projection_model_view_matrix, :libpangolin_c_api),
              Cvoid,
              (Ptr{Cvoid}, Ptr{Cdouble}),
              s_cam.c_ptr, out_ptr)
    return out
end

# void pangolin_set_model_view_matrix(void* s_cam_void_ptr, float* in){
function set_model_view_mat!(s_cam::OpenGlRenderState,
                             model_view::Matrix{Float64};
                             conversion::Bool=true)
    in_ptr = Base.unsafe_convert(Ptr{Cdouble}, model_view)
    # pangolin_get_projection_model_view_matrix
    if conversion
        ccall((:pangolin_set_model_view_matrix_with_conversion, :libpangolin_c_api),
              Cvoid,
              (Ptr{Cvoid}, Ptr{Cdouble}),
              s_cam.c_ptr, in_ptr)
    else
        ccall((:pangolin_set_model_view_matrix, :libpangolin_c_api),
              Cvoid,
              (Ptr{Cvoid}, Ptr{Cdouble}),
              s_cam.c_ptr, in_ptr)
    end
end

function Handler3D(rs::OpenGlRenderState)
    handler = ccall((:pangolin_create_handler3d, :libpangolin_c_api),
                    Ptr{Cvoid},
                    (Ptr{Cvoid},),
                    rs.c_ptr)

    Handler3D(handler)
end

# void* pangolin_create_display(void* renderstate_ptr)
function View(handler::Handler3D)
    d_cam = ccall((:pangolin_create_display, :libpangolin_c_api),
                  Ptr{Cvoid},
                  (Ptr{Cvoid},),
                  handler.c_ptr)
    View(d_cam)
end

function show(v::View; show_window::Bool=true)
    # pangolin_view_show
    ccall((:pangolin_view_show, :libpangolin_c_api),
          Cvoid,
          (Ptr{Cvoid}, Cint),
          v.c_ptr, Cint(show_window))
end

function should_quit()
    status = ccall((:pangolin_should_quit, :libpangolin_c_api),Cint, ())
    return status != 0
end

function activate(v::View, s_cam::OpenGlRenderState)
    ccall((:pangolin_view_active_render_sate, :libpangolin_c_api),
          Cvoid,
          (Ptr{Cvoid}, Ptr{Cvoid}),
          v.c_ptr, s_cam.c_ptr)
end

function glDrawColouredCube()
    ccall((:pangolin_glDrawColouredCube, :libpangolin_c_api),
          Cvoid, ())
end

# void pangolin_finish_frame()
function finish_frame()
    ccall((:pangolin_finish_frame, :libpangolin_c_api), Cvoid, ())
end

# # pangolin_destroy_window()
function destroy_window(name::String)
    ccall((:pangolin_destroy_window, :libpangolin_c_api), Cvoid, (Cstring,), name)
end

"""
int make_window_context_current(char* window_name)
return true if successful
"""
function make_window_context_current(name::String)
    res = ccall(
        (:make_window_context_current, :libpangolin_c_api),
        Cint,
        (Cstring,),
        name
    )
    return (res != 0)
end
