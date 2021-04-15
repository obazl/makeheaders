load("@bazel_skylib//lib:paths.bzl", "paths")

def _makeheaders_impl(ctx):
    # WARNING: makeheaders writes to dir containing src;
    # since the files in hdrs_srcs are symlinked to src tree
    # we need to symlink them to a (writable) bazel dir.
    # (i.e. we need to work in $GENDIR).
    # that's for source (non-generated) input files.
    # generated files are already in GENDIR, so no
    # need to link.

    multi_outputs = True
    if ctx.outputs.out:
        multi_outputs = False

    # for (k,v) in ctx.var.items():
    #     print("Var k: {}, v: {}".format(k,v))

    # print("GENDIR: %s" % ctx.genfiles_dir.path)
    # print("BLDFILE: %s" % ctx.build_file_path)

    ifiles = []
    ofiles = []
    input_args = []

    ## WARNING: special handling required for.hdrs_srcs that
    ## are (a) generated, and/or (b) located outside tgt pkg
    for src in ctx.files.hdrs_srcs:
        x = ctx.label.workspace_root + "/" + ctx.label.package
        # print("X: %s" % x)

        y = "/" + paths.dirname(src.path)
        # print("Y: %s" % y)

        # if ctx.label.package == paths.dirname(src.short_path):
        if x == y:
            if src.is_source:
                f = ctx.actions.declare_file(src.basename)
                # print("Symlinking %s" % f);
                ctx.actions.symlink(output=f, target_file = src)
                ifiles.append(f)
                input_args.append(f.path)
                o = paths.replace_extension(f.basename, ".h")
                if multi_outputs:
                    ofiles.append(ctx.actions.declare_file(o))
            else:
                ifiles.append(src)
                input_args.append(src.path)
                o = paths.replace_extension(src.basename, ".h")
                if multi_outputs:
                    ofile = ctx.actions.declare_file(o, sibling = src)
                    ofiles.append(ofile)
        else:
            if src.is_source:
                f = ctx.actions.declare_file(src.basename)
                ctx.actions.symlink(output=f, target_file = src)
                ifiles.append(f)
                input_args.append(f.path)
                o = paths.replace_extension(f.basename, ".h")
                if multi_outputs:
                    ofiles.append(ctx.actions.declare_file(o))
            else:
                ifiles.append(src)
                input_args.append(src.path)
                o = paths.replace_extension(src.basename, ".h")
                if multi_outputs:
                    ofile = ctx.actions.declare_file(o, sibling = src)
                    ofiles.append(ofile)

    ################################
    ## RENAMING: foo.c:bar.h generates bar.h instead of foo.h
    ## WARNING: full relative path on both sides of ':'
    for (tgt, hdr) in ctx.attr.hdrs_renamed.items():
        # print("SRC: {}, HDR: {}".format(tgt, hdr))
        src = tgt.files.to_list()[0]
        # print("src: %s" % src.path)

        x = ctx.label.workspace_root + "/" + ctx.label.package
        # print("X: %s" % x)
        y = "/" + paths.dirname(src.path)
        # print("Y: %s" % y)

        if x == y:
            if src.is_source:
                f = ctx.actions.declare_file(src.basename)
                ctx.actions.symlink(output=f, target_file = src)
                ifiles.append(f)
                input_args.append("{src}:{p}/{hdr}".format(
                    src = f.path,
                    p = f.dirname,
                    hdr = hdr))
                # o = paths.replace_extension(f.basename, ".h")
                if multi_outputs:
                    ofiles.append(ctx.actions.declare_file(hdr))
            else:
                ifiles.append(src)
                # input_args.append(src.path + ":" + hdr)
                input_args.append("{src}:{p}/{hdr}".format(
                    src = src.path,
                    p = src.dirname,
                    hdr = hdr))
                # o = paths.replace_extension(src.basename, ".h")
                if multi_outputs:
                    ofile = ctx.actions.declare_file(hdr, sibling = src)
                    ofiles.append(ofile)
        else:
            if src.is_source:
                f = ctx.actions.declare_file(src.basename)
                ctx.actions.symlink(output=f, target_file = src)
                ifiles.append(f)
                # input_args.append(f.path + ":" + hdr)
                input_args.append("{src}:{p}/{hdr}".format(
                    src = f.path,
                    p = f.dirname,
                    hdr = hdr))
                # o = paths.replace_extension(f.basename, ".h")
                if multi_outputs:
                    ofiles.append(ctx.actions.declare_file(hdr))
            else:
                ifiles.append(src)
                # input_args.append(src.path + ":" + hdr)
                input_args.append("{src}:{p}/{hdr}".format(
                    src = src.path,
                    p = src.dirname,
                    hdr = hdr))
                # o = paths.replace_extension(src.basename, ".h")
                if multi_outputs:
                    ofile = ctx.actions.declare_file(hdr, sibling = src)
                    ofiles.append(ofile)

    for src in ctx.files.additional_srcs:
        if ctx.label.package == paths.dirname(src.short_path):
            if src.is_source:
                f = ctx.actions.declare_file(src.basename)
                ctx.actions.symlink(output=f, target_file = src)
                ifiles.append(f)
                input_args.append(f.path + ":")
                # if multi_outputs:
                #     o = paths.replace_extension(f.basename, ".h")
                #     ofiles.append(ctx.actions.declare_file(o))
            else:
                ifiles.append(src)
                input_args.append(src.path + ":")
                # if multi_outputs:
                #     o = paths.replace_extension(src.basename, ".h")
                #     ofile = ctx.actions.declare_file(o, sibling = src)
                #     ofiles.append(ofile)
        else:
            ifiles.append(src)
            input_args.append(src.path + ":")
            # f = ctx.actions.declare_file(src.basename)
            # isrc = ctx.actions.symlink(output=f, target_file = src)
            # ifiles.append(f)
            # o = paths.replace_extension(f.basename, ".h")
            # ofiles.append(ctx.actions.declare_file(o))

    # [print("INS: %s" % i.path) for i in ifiles]
    # [print("OUTS: %s" % o.path) for o in ofiles]

    # outfiles = [ctx.actions.declare_file(x)
    #             for x in ctx.attr.outs]
    # for o in outfiles:
    #     print("OUT: %s" % o)

    exe = ctx.file._tool.path

    if multi_outputs:
        # ignore ctx.attr.export_interface
        args = ""
    else:
        if ctx.attr.export_interface:
            args = "-H"
        else:
            args = "-h"
    o = "" if multi_outputs else str(">" + ctx.outputs.out.path)
    cmd = "{mkhdrs} {args} {inputs} {o}".format(
        mkhdrs=exe,
        args = args,
        inputs = " ".join(input_args),
        o = o
    )

    # print("IFILES: %s" % ifiles)

    # print("CMD: %s" % cmd)

    ctx.actions.run_shell(
        inputs = ifiles, # + ctx.files.additional_srcs,
        outputs = ofiles if multi_outputs else [ctx.outputs.out],
        tools = [ctx.file._tool],
        command = cmd
    )

    return [DefaultInfo(files = depset(
        ofiles if multi_outputs else [ctx.outputs.out]
    ))]
    # return [DefaultInfo(files = depset(ofiles))]

###################
makeheaders = rule(
    implementation = _makeheaders_impl,
    attrs = {
        "hdrs_renamed": attr.label_keyed_string_dict(
            allow_files = [".c"],
        ),
        "hdrs_srcs": attr.label_list(
            allow_files = [".c"],
            mandatory = True
        ),
        "additional_srcs": attr.label_list(
            allow_files = [".c", ".h"],
            mandatory = False
        ),
        # "outs": attr.output_list(
        "out": attr.output(
            # mandatory = False
        ),
        "export_interface": attr.bool(
            default = True
        ),
        "local": attr.bool(
            doc = "generate prototypes for 'static' functions",
            default = False
        ),
        "docs_only": attr.bool(
            default = False
        ),
        "_tool": attr.label(
            allow_single_file = True,
            default = ":makeheaders",
            executable = True,
            cfg = "host"
        )
    }
)
