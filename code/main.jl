using ArgParse, Random, Dates

"""
    struct Config

Struct that holds parameters to be tuned and other configuration parameters.
"""
struct Config
    instance::String
    rng::Random.Xoshiro
    param1::Int
    param2::Bool
    param3::Int
    outfile::String
    errfile::String
end



"""
    struct Instance

Struct that holds a problem instance. Here, 
a minimum example with a single integer value
is used.
"""
struct Instance
    input1::Int
end



"""
    parse_commandline(ARGS) -> Config

Reads commandline arguments using `ArgParse.jl` and returns a `Config` object.
"""
function parse_commandline(ARGS)
    arg_settings = ArgParseSettings()

    @add_arg_table!(arg_settings,
    "--inst",
    begin
        help = "Path to the instance as output by the irace package."
        arg_type = String
        required = true
    end
    )
    @add_arg_table!(arg_settings,
        "--param1",
        begin
            help = "First parameter."
            arg_type = Int
            required = true
        end
    )
    @add_arg_table!(arg_settings,
    "--param2",
    begin
        help = "Second parameter."
        arg_type = Bool
        required = true
    end
    )
    @add_arg_table!(arg_settings,
    "--param3",
    begin
        help = "Third parameter."
        arg_type = Int
        required = false
        default = -1
    end
    )
    @add_arg_table!(arg_settings,
    "--seed",
    begin
        help = "Seed for random number generator. Set by irace."
        arg_type = Int
        required = true
    end
    )
    @add_arg_table!(arg_settings,
    "--outfile",
    begin   
        help = "File for stdout."
        arg_type = String
        required = true
    end
    )
    @add_arg_table!(arg_settings,
    "--errfile",
    begin
        help = "File for stderr."
        arg_type = String
        required = true
    end
    )

    commandline = parse_args(arg_settings)

    return Config(commandline["inst"], Random.Xoshiro(commandline["seed"]),
                    commandline["param1"], commandline["param2"], commandline["param3"], 
                    commandline["outfile"], commandline["errfile"])
end



"""
    parse_commandline(ARGS) -> Instance

Reads an instance .txt-file and returns a `Instance` object.
"""
function read_instance(instance::String)
    open(instance, read=true) do file
        input1 = parse(Int, readline(file))
        return Instance(input1)
    end
end



"""
    solve(config::Config) -> Int

Exemplary function that uses the input parameters and returns a result. 
"""
function solve(config::Config, instance::Instance)
    if config.param2
        result = 1/instance.input1 * (config.param1 + config.param3)
    else
        result = 1/instance.input1 * config.param1 * config.param3
    end
    return round(result, digits=8)
end



"""
    main()

Exemplary main function that is called when running the script.
"""
function main()
    # read the commandline arguments and store them in a variable of type Config
    config = parse_commandline(ARGS)

    # read the instance and store it in a variable of type Instance
    instance = read_instance(config.instance)

    # do something with the input parameters and store the result in a variable
    # the standard output and error are redirected to the files specified in the commandline arguments
    redirect_stdio(stdout=config.outfile, stderr=config.errfile) do 
        start = now()
        result = solve(config, instance)
        time = now() - start
        # prints both the result and the runtime to stdout
        println(string(result) * " " * string(time))
    end
end

# call main()
main()