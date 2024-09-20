#define DEMO_WRITER		(world.system_type == MS_WINDOWS ? "demo-writer.dll" : "libdemo-writer.so")

#define FCOPY_RSC_EMBED(resource) (SSdemo?.embed_resource(resource) || fcopy_rsc(resource))
