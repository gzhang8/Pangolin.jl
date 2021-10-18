
import Pangolin
using ModernGL


## create window

width = 640;#//1280;
height = 480;#//980;
panel = 0;#//205;
name = "Main2"

Pangolin.create_window(name, width, height)

# glEnable(GL_DEPTH_TEST);

## create s_cam

s_cam = Pangolin.OpenGlRenderState()
handler = Pangolin.Handler3D(s_cam)
## create d_cam
# void* pangolin_create_display(void* renderstate_ptr)
d_cam = Pangolin.View(handler)



while !Pangolin.should_quit()

      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
      # sleep(0.1)

      Pangolin.activate(d_cam, s_cam)
      println(Pangolin.get_projection_view_mat(s_cam))

      Pangolin.glDrawColouredCube()

      Pangolin.finish_frame()

end

Pangolin.destroy_window(name)
