
  -- Fills free disk space with zeroes.
  local partition = "/dev/sda1"              -- partition to check free space on
  local f = "./zfs_fill.dat"                 -- temporary file name

  os.execute("df \"" .. partition .. "\" > \"".. f .. "\"")
  local df = io.open(f, "r")
::no_temp_file::
  if df == nil then
    print("\nCan not open file \"".. f .. "\".\n")
    os.exit()
  end
  local f4k
  for l in df:lines() do
    if string.sub(l, 1, #partition) == partition then
      local wn = 0
      for w in string.gmatch(string.sub(l, #partition + 1, -1), "[0-9]+") do
        wn = wn + 1
        if wn == 3 then -- free 1-k blocks
          f4k = math.floor(w / 4)
          break
        end
      end
      break
    end
  end
  df:close()

  print(string.format('\nCleaning %1.3f megabytes.\n', f4k / 256))
  df = io.open(f, "w")
  if df == nil then goto no_temp_file end
  local w4k = string.rep(string.char(0), 4096)
  for i = 1, f4k do
    df:write(w4k)
    print(string.format('\027[1A\027[K\027[1000D%1.3f%%.', i / f4k * 100))
  end
  df:close()
  os.remove(f)
  print("Finished.\n")

